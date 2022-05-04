terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }

  backend "local" {
    path = "local_tf_state/terraform-main.tfstate"
  }
}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

provider "aws" {
  region = var.region
  alias  = "default"
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

locals {
  tenant          = var.tenant      # AWS account name or unique id for tenant
  environment     = var.environment # Environment area eg., preprod or prod
  zone            = var.zone        # Environment with in one sub_tenant or business unit
  cluster_version = var.cluster_version

  vpc_cidr     = "10.0.0.0/16"
  vpc_name     = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.0.1"

  ca_expander          = "priority"
  ca_priority_expander = <<-EOT
    100:
      - .*-spot-.*
    10:
      - .*
  EOT
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.2.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
#---------------------------------------------------------------
# Example to consume eks_blueprints module
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  cluster_version = local.cluster_version

  # EKS SELF MANAGED NODE GROUPS
  self_managed_node_groups = {
    ondemand_2vcpu_8mem = {
      node_group_name    = "smng-ondemand-2vcpu-8mem"
      instance_types     = ["m5.large"]
      min_size           = "2"
      subnet_ids         = module.aws_vpc.private_subnets
      launch_template_os = "amazonlinux2eks" # amazonlinux2eks or bottlerocket
    }

    spot_2vcpu_8mem = {
      node_group_name    = "smng-spot-2vcpu-8mem"
      capacity_type      = "spot"
      capacity_rebalance = true
      instance_types     = ["m5.large", "m4.large", "m6a.large", "m5a.large", "m5d.large"]
      min_size           = "0"
      subnet_ids         = module.aws_vpc.private_subnets
      launch_template_os = "amazonlinux2eks" # amazonlinux2eks or bottlerocket
    }

    spot_4vcpu_16mem = {
      node_group_name    = "smng-spot-4vcpu-16mem"
      capacity_type      = "spot"
      capacity_rebalance = true
      instance_types     = ["m5.xlarge", "m4.xlarge", "m6a.xlarge", "m5a.xlarge", "m5d.xlarge"]
      min_size           = "0"
      subnet_ids         = module.aws_vpc.private_subnets
      launch_template_os = "amazonlinux2eks" # amazonlinux2eks or bottlerocket
    }
  }
}

module "eks_blueprints_kubernetes_addons" {
  source                   = "../../../modules/kubernetes-addons"
  eks_cluster_id           = module.eks_blueprints.eks_cluster_id
  auto_scaling_group_names = module.eks_blueprints.self_managed_node_group_autoscaling_groups

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  #K8s Add-ons
  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
  enable_aws_node_termination_handler = true

  enable_cluster_autoscaler = true
  cluster_autoscaler_helm_config = {
    set = [
      {
        name  = "extraArgs.expander"
        value = local.ca_expander
      },
      {
        name  = "expanderPriorities"
        value = local.ca_priority_expander
      }
    ]
  }

  depends_on = [module.eks_blueprints.managed_node_groups]
}
