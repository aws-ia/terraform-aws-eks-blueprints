provider "aws" {
  region = var.region
  alias  = "default"
}

data "aws_availability_zones" "available" {}

locals {
  cloud9_vpc_name  = var.cloud9_vpc_name
  cloud9_vpc_cidr  = var.cloud9_vpc_cidr
  cloud9_owner_arn = var.cloud9_owner_arn

  vpc_cidr = var.eks_vpc_cidr
  vpc_name = var.eks_vpc_name
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.vpc_name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "cloud9_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.cloud9_vpc_name
  cidr = local.cloud9_vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.cloud9_vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.cloud9_vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.cloud9_vpc_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.cloud9_vpc_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.cloud9_vpc_name}-default" }

  tags = local.tags
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 2, k)]

  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.vpc_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.vpc_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.vpc_name}-default" }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.vpc_name}" = "shared"
    "kubernetes.io/role/internal-elb"         = 1
  }

  tags = local.tags

  default_security_group_name = "${local.vpc_name}-endpoint-secgrp"
  default_security_group_ingress = [
    {
      protocol    = -1
      from_port   = 0
      to_port     = 0
      cidr_blocks = local.vpc_cidr
      }, {
      protocol    = -1
      from_port   = 0
      to_port     = 0
      cidr_blocks = var.cloud9_vpc_cidr # Allow ingress from the default VPC CIDR range so the bastion host/Jenkins server can access the EKS private endpoint.
  }]
  default_security_group_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
  }]

}

module "vpc_endpoints_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.vpc_name}-vpc-endpoints"
  description = "Security group for VPC endpoint access"
  vpc_id      = module.aws_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      description = "VPC CIDR HTTPS"
      cidr_blocks = join(",", module.aws_vpc.private_subnets_cidr_blocks)
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      description = "All egress HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = local.tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 3.0"

  vpc_id             = module.aws_vpc.vpc_id
  security_group_ids = [module.vpc_endpoints_sg.security_group_id]

  endpoints = merge({
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.aws_vpc.private_route_table_ids
      tags = {
        Name = "${local.vpc_name}-s3"
      }
    }
    },
    { for service in toset(["autoscaling", "ecr.api", "ecr.dkr", "ec2", "ec2messages", "elasticloadbalancing", "sts", "kms", "logs", "ssm", "ssmmessages"]) :
      replace(service, ".", "_") =>
      {
        service             = service
        subnet_ids          = module.aws_vpc.private_subnets
        private_dns_enabled = true
        tags                = { Name = "${local.vpc_name}-${service}" }
      }
  })

  tags = local.tags
}
