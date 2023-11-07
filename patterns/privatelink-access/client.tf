# The resources defined in this file are only used for demonstrating private connectivity
# They are not required for the solution

locals {
  client_name = "${local.name}-client"
}

################################################################################
# VPC
################################################################################

module "client_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.client_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.client_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.client_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.client_name}-default" }

  tags = merge(local.tags, {
    Name = local.client_name
  })
}

################################################################################
# EC2 Instance
################################################################################

module "client_ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = local.client_name

  create_iam_instance_profile = true
  iam_role_policies = {
    EKSFullAccess                = aws_iam_policy.eks_full_access_policy.arn
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_security_group_ids = [module.client_security_group.security_group_id]
  subnet_id              = element(module.client_vpc.private_subnets, 0)

  user_data = <<-EOT
    #!/bin/bash

    # Install kubectl
    curl -LO https://dl.k8s.io/release/v${module.eks.cluster_version}.0/bin/linux/amd64/kubectl
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    # Remove default awscli which is v1 - we want latest v2
    yum remove awscli -y
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -qq awscliv2.zip
    ./aws/install
  EOT

  tags = merge(local.tags, {
    Name = local.client_name
  })
}

resource "aws_iam_policy" "eks_full_access_policy" {
  name        = "EKSFullAccess"
  path        = "/"
  description = "EKS full-access policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Effect   = "Allow"
        Resource = module.eks.cluster_arn
      },
    ]
  })
}

module "client_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.client_name
  description = "Security group for SSM access to private cluster"
  vpc_id      = module.client_vpc.vpc_id

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = merge(local.tags, {
    Name = local.client_name
  })
}
