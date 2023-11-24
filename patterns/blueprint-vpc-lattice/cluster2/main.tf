provider "aws" {
  region = local.region
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

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

data "aws_availability_zones" "available" {}
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}
data "aws_caller_identity" "identity" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  vpc_cidr = "192.168.48.0/20"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

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
  version = "~> 19.16"

  cluster_name                   = local.name
  cluster_version                = "1.27" # Must be 1.25 or higher
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
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
# EKS Addons (demo application)
################################################################################

module "addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # EKS Addons
  eks_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      preserve    = true
      most_recent = true # Must be 1.14.0 or higher

      timeouts = {
        create = "25m"
        delete = "10m"
      }

    }
  }
  enable_aws_gateway_api_controller = true
  aws_gateway_api_controller = {
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
    # awsRegion, clusterVpcId, clusterName, awsAccountId are required for case where IMDS is NOT AVAILABLE, e.g Fargate, self-managed clusters with IMDS access blocked
    set = [{
      name  = "clusterVpcId"
      value = module.vpc.vpc_id
    },
      {
        name = "clusterName"
        value = module.eks.cluster_name
      }
    ]

  }
  tags = local.tags
}

data "aws_ec2_managed_prefix_list" "ipv4" {
  name = "com.amazonaws.${local.region}.vpc-lattice"
}


# configure security group to receive traffic from the VPC Lattice network. You must set up security groups so that they allow all Pods communicating with VPC Lattice to allow traffic from the VPC Lattice managed prefix lists. Lattice has both an IPv4 and IPv6 prefix lists available
resource "aws_security_group_rule" "vpc_lattice_ipv4_ingress" {
  description       = "VPC lattice ipv4 ingress"
  type              = "ingress"
  security_group_id = module.eks.cluster_security_group_id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.ipv4.id]
}
