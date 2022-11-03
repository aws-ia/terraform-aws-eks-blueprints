provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  cluster_version = "1.23"

  azs                = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_cidr           = "10.0.0.0/16"
  secondary_vpc_cidr = "10.99.0.0/16"

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "../.."

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = slice(module.vpc.private_subnets, 0, 3)
  control_plane_subnet_ids = module.vpc.intra_subnets

  # https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/485
  # https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/494
  cluster_kms_key_additional_admin_arns = [data.aws_caller_identity.current.arn]

  managed_node_groups = {
    custom_networking = {
      node_group_name = "custom-net"

      min_size     = 1
      max_size     = 3
      desired_size = 2

      custom_ami_id  = data.aws_ssm_parameter.eks_optimized_ami.value
      instance_types = ["m5.xlarge"]

      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"

      # https://docs.aws.amazon.com/eks/latest/userguide/choosing-instance-type.html#determine-max-pods
      pre_userdata = <<-EOT
        MAX_PODS=$(/etc/eks/max-pods-calculator.sh \
        --instance-type-from-imds \
        --cni-version ${trimprefix(data.aws_eks_addon_version.latest["vpc-cni"].version, "v")} \
        --cni-prefix-delegation-enabled \
        --cni-custom-networking-enabled \
        )
      EOT

      # These settings opt out of the default behavior and use the maximum number of pods, with a cap of 110 due to
      # Kubernetes guidance https://kubernetes.io/docs/setup/best-practices/cluster-large/
      # See more info here https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
      kubelet_extra_args   = "--max-pods=$${MAX_PODS}"
      bootstrap_extra_args = "--use-max-pods false"
    }
  }

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  enable_amazon_eks_vpc_cni = true
  amazon_eks_vpc_cni_config = {
    # Version 1.6.3-eksbuild.2 or later of the Amazon VPC CNI is required for custom networking
    # Version 1.9.0 or later (for version 1.20 or earlier clusters or 1.21 or later clusters configured for IPv4)
    # or 1.10.1 or later (for version 1.21 or later clusters configured for IPv6) of the Amazon VPC CNI for prefix delegation
    addon_version     = data.aws_eks_addon_version.latest["vpc-cni"].version
    resolve_conflicts = "OVERWRITE"
  }

  tags = local.tags

  depends_on = [
    # Modify VPC CNI ahead of addons
    null_resource.kubectl_set_env
  ]
}

data "aws_eks_addon_version" "latest" {
  for_each = toset(["vpc-cni"])

  addon_name         = each.value
  kubernetes_version = module.eks_blueprints.eks_cluster_version
  most_recent        = true
}

#---------------------------------------------------------------
# Modify VPC CNI deployment
#---------------------------------------------------------------

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks_blueprints.eks_cluster_id
      cluster = {
        certificate-authority-data = module.eks_blueprints.eks_cluster_certificate_authority_data
        server                     = module.eks_blueprints.eks_cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks_blueprints.eks_cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })
}

resource "null_resource" "kubectl_set_env" {
  triggers = {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }

    # Reference https://aws.github.io/aws-eks-best-practices/reliability/docs/networkmanagement/#cni-custom-networking
    # Reference https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
    command = <<-EOT
      # Custom networking
      kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true --kubeconfig <(echo $KUBECONFIG | base64 -d)
      kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone --kubeconfig <(echo $KUBECONFIG | base64 -d)


      # Prefix delegation
      kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true --kubeconfig <(echo $KUBECONFIG | base64 -d)
      kubectl set env daemonset aws-node -n kube-system WARM_PREFIX_TARGET=1 --kubeconfig <(echo $KUBECONFIG | base64 -d)
    EOT
  }
}

#---------------------------------------------------------------
# VPC-CNI Custom Networking ENIConfig
#---------------------------------------------------------------

resource "kubectl_manifest" "eni_config" {
  for_each = zipmap(local.azs, slice(module.vpc.private_subnets, 3, 6))

  yaml_body = yamlencode({
    apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
    kind       = "ENIConfig"
    metadata = {
      name = each.key
    }
    spec = {
      securityGroups = [
        module.eks_blueprints.cluster_primary_security_group_id,
        module.eks_blueprints.worker_node_security_group_id,
      ]
      subnet = each.value
    }
  })
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

data "aws_ssm_parameter" "eks_optimized_ami" {
  name = "/aws/service/eks/optimized-ami/${local.cluster_version}/amazon-linux-2/recommended/image_id"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  secondary_cidr_blocks = [local.secondary_vpc_cidr] # can add up to 5 total CIDR blocks

  azs = local.azs
  private_subnets = concat(
    [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)],
    [for k, v in local.azs : cidrsubnet(local.secondary_vpc_cidr, 2, k)]
  )
  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}
