provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  cluster_vpc_cidr = "10.0.0.0/16"
  client_vpc_cidr  = "10.1.0.0/16"
  azs              = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21"

  cluster_name                   = local.name
  cluster_version                = "1.28"
  cluster_endpoint_public_access = true
  enable_irsa                    = true

  vpc_id     = module.cluster_vpc.vpc_id
  subnet_ids = module.cluster_vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 3
      max_size     = 10
      desired_size = 3
    }
  }

  tags = local.tags
}

################################################################################
# Cluster VPC
################################################################################

module "cluster_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.4"

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

################################################################################
# EKS Addons (AWS Gateway API Controller)
################################################################################

module "addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.12"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_gateway_api_controller = true
  aws_gateway_api_controller = {
    chart_version           = "v1.0.2"
    create_namespace        = true
    namespace               = "aws-application-networking-system"
    source_policy_documents = [data.aws_iam_policy_document.gateway_api_controller.json]
    set = [
      {
        name  = "clusterName"
        value = module.eks.cluster_name
      },
      {
        name  = "log.level"
        value = "debug"
      },
      {
        name  = "clusterVpcId"
        value = module.cluster_vpc.vpc_id
    }, ]
    wait = true
  }


  tags = local.tags
}

data "aws_iam_policy_document" "gateway_api_controller" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"] # For testing purposes only (highly recommended limit access to specific resources for production usage)

    actions = [
      "vpc-lattice:*",
      "iam:CreateServiceLinkedRole",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeSecurityGroups",
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "tag:GetResources",
    ]
  }
}

################################################################################
# Demo applications
################################################################################

resource "helm_release" "demo_application" {
  name             = "demo-application"
  chart            = "./charts/demo-application"
  create_namespace = true
  namespace        = "apps"

  depends_on = [module.addons]
}

################################################################################
# Update cluster security group to allow access from VPC Lattice
################################################################################

data "aws_ec2_managed_prefix_list" "vpc_lattice_ipv4" {
  name = "com.amazonaws.${local.region}.vpc-lattice"
}

resource "aws_vpc_security_group_ingress_rule" "cluster_sg_ingress" {
  security_group_id = module.eks.node_security_group_id

  prefix_list_id = data.aws_ec2_managed_prefix_list.vpc_lattice_ipv4.id
  ip_protocol    = "-1"
}

################################################################################
# VPC Lattice service network
################################################################################

resource "aws_vpclattice_service_network" "this" {
  name      = "my-services"
  auth_type = "NONE"

  tags = local.tags
}

resource "aws_vpclattice_service_network_vpc_association" "cluster_vpc" {
  vpc_identifier             = module.cluster_vpc.vpc_id
  service_network_identifier = aws_vpclattice_service_network.this.id
}

resource "aws_vpclattice_service_network_vpc_association" "client_vpc" {
  vpc_identifier             = module.client_vpc.vpc_id
  service_network_identifier = aws_vpclattice_service_network.this.id
}

resource "time_sleep" "wait_for_lattice_resources" {
  depends_on = [helm_release.demo_application]

  create_duration = "120s"
}

data "aws_vpclattice_service" "server" {
  name = "server-apps"

  tags = local.tags

  depends_on = [time_sleep.wait_for_lattice_resources]
}

################################################################################
# Custom domain name for VPC lattice service
################################################################################

resource "aws_route53_zone" "primary" {
  name = "example.com"

  vpc {
    vpc_id = module.client_vpc.vpc_id
  }

  tags = local.tags
}

resource "aws_route53_record" "record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "server.example.com"
  type    = "CNAME"
  ttl     = 300
  records = [lookup(data.aws_vpclattice_service.server.dns_entry[0], "domain_name", "")]
}

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
