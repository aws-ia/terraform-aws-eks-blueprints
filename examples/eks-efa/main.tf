# Providers

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# Data

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {}

data "http" "efa_device_plugin_yaml" {
  url = "https://raw.githubusercontent.com/aws-samples/aws-efa-eks/main/manifest/efa-k8s-device-plugin.yml"
}

data "aws_ami" "eks_gpu_node" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-gpu-node-${local.cluster_version}-*"]
  }
}

# Local config

locals {
  name            = var.cluster_name
  cluster_version = "1.25"

  vpc_cidr = "10.11.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

}

# Resources

resource "aws_placement_group" "efa_pg" {
  name     = "efa_pg"
  strategy = "cluster"
}

resource "kubectl_manifest" "efa_device_plugin" {
  yaml_body = <<YAML
${data.http.efa_device_plugin_yaml.response_body}
YAML
}

resource "helm_release" "k8s_device_plugin" {
  name       = "k8s-device-plugin"
  repository = "https://nvidia.github.io/k8s-device-plugin"
  chart      = "nvidia-device-plugin"
  version    = "0.14.0"
  namespace  = "kube-system"
}

# Upstream Terraform Modules

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.12"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = var.cluster_enabled_log_types

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  eks_managed_node_groups = {
    sys = {
      instance_types = ["m5.large"]
      min_size       = 1
      max_size       = 5
      desired_size   = 2
    }
  }

  create_aws_auth_configmap = false
  manage_aws_auth_configmap = true

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ingress traffic"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_self_all = {
      description = "Node to node all egress traffic"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      self        = true
    }
  }


  self_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    placement = {
      group_name = aws_placement_group.efa_pg.name
    }
  }

  self_managed_node_groups = {
    efa = {
      min_size     = 2
      max_size     = 8
      desired_size = 2

      #instance_type = "c5n.9xlarge"
      instance_type = "g4dn.metal"
      ami_id        = data.aws_ami.eks_gpu_node.id

      ebs_optimized     = true
      enable_monitoring = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 40
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      subnet_ids = [module.vpc.private_subnets[0]]

      network_interfaces = [
        {
          description                 = "EFA interface"
          delete_on_termination       = true
          device_index                = 0
          associate_public_ip_address = false
          interface_type              = "efa"
        }
      ]

      post_bootstrap_user_data = <<-EOT
        # Install EFA
        curl -O https://efa-installer.amazonaws.com/aws-efa-installer-latest.tar.gz
        tar -xf aws-efa-installer-latest.tar.gz && cd aws-efa-installer
        ./efa_installer.sh -y
        fi_info -p efa -t FI_EP_RDM
        # Disable ptrace
        sysctl -w kernel.yama.ptrace_scope=0
      EOT

    }
  }

  tags = local.tags
}

# Blueprints modules

module "eks_blueprints_kubernetes_addons" {
  source = "../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_oidc_provider    = module.eks.oidc_provider
  eks_cluster_version  = module.eks.cluster_version

  # Wait on the node group(s) before provisioning addons
  data_plane_wait_arn = join(",", [for group in module.eks.eks_managed_node_groups : group.node_group_arn])

  enable_amazon_eks_aws_ebs_csi_driver = false
  enable_aws_efs_csi_driver            = true
  enable_aws_fsx_csi_driver            = true

  tags = local.tags
}

# Supporting modules

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
