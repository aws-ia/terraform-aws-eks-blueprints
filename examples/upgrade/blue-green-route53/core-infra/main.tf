provider "aws" {
  region = local.region
}

locals {
  name   = var.core_stack_name
  region = var.aws_region

  vpc_cidr       = var.vpc_cidr
  num_of_subnets = min(length(data.aws_availability_zones.available.names), 3)
  azs            = slice(data.aws_availability_zones.available.names, 0, local.num_of_subnets)

  argocd_secret_manager_name = var.argocd_secret_manager_name_suffix

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}-blue"  = "shared"
    "kubernetes.io/cluster/${local.name}-green" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}-blue"  = "shared"
    "kubernetes.io/cluster/${local.name}-green" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }

  tags = local.tags
}

# Retrieve existing root hosted zone
data "aws_route53_zone" "root" {
  name = var.hosted_zone_name
}

# Create Sub HostedZone four our deployment
resource "aws_route53_zone" "sub" {
  name = "${local.name}.${var.hosted_zone_name}"
}

# Validate records for the new HostedZone
resource "aws_route53_record" "ns" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${local.name}.${var.hosted_zone_name}"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.sub.name_servers
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "${local.name}.${var.hosted_zone_name}"
  zone_id     = aws_route53_zone.sub.zone_id

  subject_alternative_names = [
    "*.${local.name}.${var.hosted_zone_name}"
  ]

  wait_for_validation = true

  tags = {
    Name = "${local.name}.${var.hosted_zone_name}"
  }
}

#---------------------------------------------------------------
# ArgoCD Admin Password credentials with Secrets Manager
# Login to AWS Secrets manager with the same role as Terraform to extract the ArgoCD admin password with the secret name as "argocd"
#---------------------------------------------------------------
resource "random_password" "argocd" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "arogcd" {
  name                    = "${local.argocd_secret_manager_name}.${local.name}"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "arogcd" {
  secret_id     = aws_secretsmanager_secret.arogcd.id
  secret_string = random_password.argocd.result
}
