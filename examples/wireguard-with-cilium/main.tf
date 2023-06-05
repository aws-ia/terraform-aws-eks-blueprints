provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)


  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = local.name
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true

  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]
      # Cilium Wireguard requires Linux Kernel 5.10 or aboved.
      # For EKS 1.24 and above, the AMI the Kernerl version is 5.10
      # For EKS 1.23 and below, you need to use Bottlerocket OS. For example:
      #    ami_type = "BOTTLEROCKET_x86_64"
      #    platform = "bottlerocket"
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_cilium_wireguard = {
      description = "Allow Cilium Wireguard node to node"
      protocol    = "udp"
      from_port   = 51871
      to_port     = 51871 # Cilium Wireguard Port https://github.com/cilium/cilium/blob/main/Documentation/security/network/encryption-wireguard.rst
      type        = "ingress"
      self        = true
    }
  }

  tags = local.tags
}

################################################################################
# Cilium Helm Chart for e2e encryption with Wireguard
################################################################################

resource "helm_release" "cilium" {
  name             = "cilium"
  chart            = "cilium"
  version          = "1.13.2"
  repository       = "https://helm.cilium.io/"
  description      = "Cilium Add-on"
  namespace        = "kube-system"
  create_namespace = false

  values = [
    <<-EOT
      cni:
        chainingMode: aws-cni
      enableIPv4Masquerade: false
      tunnel: disabled
      endpointRoutes:
        enabled: true
      l7Proxy: false
      encryption:
        enabled: true
        type: wireguard
    EOT
  ]

  depends_on = [
    module.eks
  ]
}

#---------------------------------------------------------------
# Sample App for Testing
#---------------------------------------------------------------

# For some reason the example pods can't be deployed right after helm install of cilium a delay needs to be introduced. This is being investigated
resource "time_sleep" "wait_wireguard" {
  count           = var.enable_example ? 1 : 0
  create_duration = "15s"

  depends_on = [helm_release.cilium]
}

resource "kubectl_manifest" "server" {
  count = var.enable_example ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Pod"
    metadata = {
      name = "server"
      labels = {
        blog = "wireguard"
        name = "server"
      }
    }
    spec = {
      containers = [
        {
          name  = "server"
          image = "nginx"
        }
      ]
      topologySpreadConstraints = [
        {
          maxSkew           = 1
          topologyKey       = "kubernetes.io/hostname"
          whenUnsatisfiable = "DoNotSchedule"
          labelSelector = {
            matchLabels = {
              blog = "wireguard"
            }
          }
        }
      ]
    }
  })

  depends_on = [time_sleep.wait_wireguard]
}

resource "kubectl_manifest" "service" {
  count = var.enable_example ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name = "server"
    }
    spec = {
      selector = {
        name = "server"
      }
      ports = [
        {
          port = 80
        }
      ]
    }
  })
}

resource "kubectl_manifest" "client" {
  count = var.enable_example ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Pod"
    metadata = {
      name = "client"
      labels = {
        blog = "wireguard"
        name = "client"
      }
    }
    spec = {
      containers = [
        {
          name    = "client"
          image   = "busybox"
          command = ["watch", "wget", "server"]
        }
      ]
      topologySpreadConstraints = [
        {
          maxSkew           = 1
          topologyKey       = "kubernetes.io/hostname"
          whenUnsatisfiable = "DoNotSchedule"
          labelSelector = {
            matchLabels = {
              blog = "wireguard"
            }
          }
        }
      ]
    }
  })

  depends_on = [kubectl_manifest.server]
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

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
