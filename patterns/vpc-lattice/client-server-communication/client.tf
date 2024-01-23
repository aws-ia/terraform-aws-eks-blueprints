################################################################################
# Client application (with private access over SSM Systems Manager)
################################################################################

module "client" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"

  name = "client"

  instance_type               = "t2.micro"
  subnet_id                   = module.client_vpc.private_subnets[0]
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for client"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  vpc_security_group_ids = [module.client_sg.security_group_id]

  tags = local.tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = module.client_vpc.vpc_id

  endpoints = { for service in toset(["ssm", "ssmmessages", "ec2messages"]) :
    replace(service, ".", "_") =>
    {
      service             = service
      subnet_ids          = module.client_vpc.private_subnets
      private_dns_enabled = true
      tags                = { Name = "${local.name}-${service}" }
    }
  }

  security_group_ids = [module.endpoint_sg.security_group_id]

  tags = local.tags
}

module "client_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "client"
  description = "Security Group for EC2 Instance Egress"

  vpc_id = module.client_vpc.vpc_id

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"

    },
  ]

  tags = local.tags
}

module "endpoint_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "ssm-endpoint"
  description = "Security Group for EC2 Instance Egress"

  vpc_id = module.client_vpc.vpc_id

  ingress_with_cidr_blocks = [for subnet in module.client_vpc.private_subnets_cidr_blocks :
    {
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      cidr_blocks = subnet
    }
  ]

  tags = local.tags
}

################################################################################
# Client VPC
################################################################################

module "client_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.4"

  name = local.name
  cidr = local.client_vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.client_vpc_cidr, 4, k)]

  tags = local.tags
}
