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


data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"
  azs    = ["${local.region}a", "${local.region}b", "${local.region}c"]
  
  vpc_name           = "eks-vpc"
  vpc_cidr           = "10.16.0.0/24"
  vpc_2nd_cidr       = "100.16.0.0/16"
  public_subnets     = ["10.16.0.192/26"]
  primary_subnets    = ["10.16.0.0/26", "10.16.0.64/26", "10.16.0.128/26"]
  secondary_subnets = ["100.16.0.0/24", "100.16.1.0/24", "100.16.2.0/24"]
  
  # map_users = [
  #   {
  #     userarn  = "admin-user-arn"
  #     username = "adminruser"
  #     groups   = ["system:masters"]
  #   }
  # ]

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  
  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.primary_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

# Create 2nd CIDR out of VPC to have a separated list of 2nd subnets depend on this association
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = local.vpc_2nd_cidr
}

# Create 2nd CIDR subnets out of VPC to pass them directly to EKS module
resource "aws_subnet" "secondary_subs" {
  count = length(local.secondary_subnets)

  vpc_id            = module.vpc.vpc_id
  cidr_block        = local.secondary_subnets[count.index]
  availability_zone = element(local.azs, count.index)
  depends_on        = [aws_vpc_ipv4_cidr_block_association.secondary_cidr]
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../.."

  cluster_name    = local.name
  cluster_version = "1.22"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  pod_subnet_ids     = aws_subnet.secondary_subs[*].id    # assign pod_subnet_ids list to enable CNI custom network
  
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m3.medium"]
      subnet_ids      = module.vpc.private_subnets
    }
  }
  
  self_managed_node_groups = {
    self_mg4 = {
      node_group_name    = "self_mg4"
      launch_template_os = "amazonlinux2eks"
      subnet_ids         = module.vpc.private_subnets
    }
  }
  
  map_users = local.map_users

  tags = local.tags
}

output "kubeconfig" {
  value = module.eks_blueprints.configure_kubectl
}