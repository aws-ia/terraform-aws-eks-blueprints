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

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
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

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../../.."

  cluster_name    = local.name
  cluster_version = "1.23"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    mng_spot_medium = {
      node_group_name = "mng-spot-med"
      capacity_type   = "SPOT"
      instance_types  = ["t3.large", "t3.xlarge"]
      subnet_ids      = module.vpc.private_subnets
      desired_size    = 2
      disk_size       = 30
    }
  }

  enable_windows_support = true
  self_managed_node_groups = {
    ng_od_windows = {
      node_group_name    = "ng-od-windows"
      launch_template_os = "windows"
      instance_type      = "m5.large"
      subnet_ids         = module.vpc.private_subnets
      min_size           = 2
    }
  }

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # EKS Managed Add-ons
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  # Add-ons
  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller_helm_config = {
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
  }

  enable_metrics_server = true
  metrics_server_helm_config = {
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
  }

  enable_cluster_autoscaler = true
  cluster_autoscaler_helm_config = {
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
  }

  tags = local.tags

}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

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
