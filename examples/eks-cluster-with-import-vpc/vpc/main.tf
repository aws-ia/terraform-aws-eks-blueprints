provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  region      = "us-west-2"

  vpc_cidr       = var.vpc_cidr
  vpc_name       = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  azs            = slice(data.aws_availability_zones.available.names, 0, 3)
  eks_cluster_id = join("-", [local.tenant, local.environment, local.zone, "eks"])
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

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
    "kubernetes.io/cluster/${local.eks_cluster_id}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_id}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}
