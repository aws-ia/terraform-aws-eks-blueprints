################################################################################
# Cluster VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.cluster_vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.cluster_vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.cluster_vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

################################################################################
# Associate private_hosted_zone with VPC
################################################################################

resource "aws_route53_zone_association" "private_zone_association" { 
  zone_id = data.terraform_remote_state.environment.outputs.private_zone_id 
  vpc_id = module.vpc.vpc_id 
}