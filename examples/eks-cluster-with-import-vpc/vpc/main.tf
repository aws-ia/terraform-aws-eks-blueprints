provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone

  vpc_cidr       = var.vpc_cidr
  vpc_name       = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  eks_cluster_id = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.0.1"
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.2.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = data.aws_availability_zones.available.names

  public_subnets  = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(local.vpc_cidr, 8, k + 10)]

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
