provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = format("%s-%s", basename(path.cwd), "shared")
  region       = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  istio_chart_url     = "https://istio-release.storage.googleapis.com/charts"
  istio_chart_version = "1.18.1"

  tags = {
    Blueprint  = local.cluster_name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.cluster_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

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
# Cluster 1 additional security group for cross cluster communication
################################################################################

resource "aws_security_group" "cluster1_additional_sg" {
  name        = "cluster1_additional_sg"
  description = "Allow communication from cluster2 SG to cluster1 SG"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "cluster1_additional_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "cluster1_additional_sg_allow_all_4" {
  security_group_id = aws_security_group.cluster1_additional_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "cluster1_additional_sg_allow_all_6" {
  security_group_id = aws_security_group.cluster1_additional_sg.id

  ip_protocol = "-1"
  cidr_ipv6   = "::/0"
}

################################################################################
# Cluster 2 additional security group for cross cluster communication
################################################################################

resource "aws_security_group" "cluster2_additional_sg" {
  name        = "cluster2_additional_sg"
  description = "Allow communication from cluster1 SG to cluster2 SG"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "cluster2_additional_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "cluster2_additional_sg_allow_all_4" {
  security_group_id = aws_security_group.cluster2_additional_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
resource "aws_vpc_security_group_egress_rule" "cluster2_additional_sg_allow_all_6" {
  security_group_id = aws_security_group.cluster2_additional_sg.id

  ip_protocol = "-1"
  cidr_ipv6   = "::/0"
}

################################################################################
# cross SG  ingress rules Cluster 2 allow to cluster 1
################################################################################

resource "aws_vpc_security_group_ingress_rule" "cluster2_to_cluster_1" {
  security_group_id = aws_security_group.cluster1_additional_sg.id

  referenced_security_group_id = aws_security_group.cluster2_additional_sg.id
  ip_protocol                  = "-1"
}

################################################################################
# cross SG  ingress rules Cluster 1 allow to cluster 2
################################################################################

resource "aws_vpc_security_group_ingress_rule" "cluster1_to_cluster_2" {
  security_group_id = aws_security_group.cluster2_additional_sg.id

  referenced_security_group_id = aws_security_group.cluster1_additional_sg.id
  ip_protocol                  = "-1"
}
