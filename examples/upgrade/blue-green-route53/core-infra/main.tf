provider "aws" {
  region = local.region
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
    "kubernetes.io/cluster/${local.name}-blue"     = "shared"
    "kubernetes.io/cluster/${local.name}-green"    = "shared"
    "kubernetes.io/cluster/${local.name}-nodomain" = "shared"
    "kubernetes.io/role/elb"                       = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}-blue"     = "shared"
    "kubernetes.io/cluster/${local.name}-green"    = "shared"
    "kubernetes.io/cluster/${local.name}-nodomain" = "shared"
    "kubernetes.io/role/internal-elb"              = "1"
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

# Create wildcard certificate four our zone
resource "aws_acm_certificate" "sub" {
  domain_name               = "${local.name}.${var.hosted_zone_name}"
  subject_alternative_names = ["*.${local.name}.${var.hosted_zone_name}"]
  validation_method         = "DNS"
}

# Validate Certificate records for the new HostedZone
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.sub.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.sub.zone_id
}

resource "aws_acm_certificate_validation" "sub" {
  certificate_arn         = aws_acm_certificate.sub.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
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
