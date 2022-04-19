provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

data "aws_availability_zones" "available" {}

data "aws_acm_certificate" "issued" {
  domain   = var.acm_certificate_domain
  statuses = ["ISSUED"]
}

locals {
  tenant      = "aws001"  # AWS account name or unique id for tenant
  environment = "preprod" # Environment area eg., preprod or prod
  zone        = "dev"     # Environment with in one sub_tenant or business unit
  region      = "us-west-2"

  vpc_cidr     = "10.0.0.0/16"
  vpc_name     = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)

  terraform_version = "Terraform v1.0.1"
}

#---------------------------------------------------------------
# VPC
#---------------------------------------------------------------

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  create_igw           = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

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
# Example to consume eks_cluster module
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  cluster_version = "1.21"

  # Managed Node Group
  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m4.large"]
      min_size        = "2"
      subnet_ids      = module.aws_vpc.private_subnets
    }
  }
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../modules/kubernetes-addons"

  #---------------------------------------------------------------
  # Globals
  #---------------------------------------------------------------

  eks_cluster_id     = module.eks_blueprints.eks_cluster_id
  eks_cluster_domain = var.eks_cluster_domain

  #---------------------------------------------------------------
  # ARGO CD ADD-ON
  #---------------------------------------------------------------

  enable_argocd = true
  argocd_applications = {
    workloads = {
      path     = "envs/dev"
      repo_url = "https://github.com/aws-samples/eks_blueprints-workloads.git"
      values = {
        spec = {
          ingress = {
            host = var.eks_cluster_domain
          }
        }
      }
    }
  }

  #---------------------------------------------------------------
  # INGRESS NGINX ADD-ON
  #---------------------------------------------------------------

  enable_ingress_nginx = true
  ingress_nginx_helm_config = {
    values = [templatefile("${path.module}/nginx-values.yaml", {
      hostname     = var.eks_cluster_domain
      ssl_cert_arn = data.aws_acm_certificate.issued.arn
    })]
  }

  #---------------------------------------------------------------
  # OTHER ADD-ONS
  #---------------------------------------------------------------

  enable_aws_load_balancer_controller = true
  enable_external_dns                 = true

  depends_on = [
    module.aws_vpc,
    module.eks_blueprints.managed_node_groups
  ]
}
