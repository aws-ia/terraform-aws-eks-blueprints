provider "aws" {
  region = local.region
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

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  cluster_version = "1.29"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  gameserver_minport = 7000
  gameserver_maxport = 8000

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
  version = "~> 20.0"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  # Give the Terraform identity admin access to the cluster
  # which will allow resources to be deployed into the cluster
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.private_subnets
  subnet_ids               = module.vpc.public_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["m5.large"]
      min_size       = 1
      max_size       = 5
      desired_size   = 2
    }

    agones_system = {
      instance_types = ["m5.large"]
      labels = {
        "agones.dev/agones-system" = true
      }
      taint = {
        dedicated = {
          key    = "agones.dev/agones-system"
          value  = true
          effect = "NO_EXECUTE"
        }
      }
      min_size     = 1
      max_size     = 1
      desired_size = 1
    }

    agones_metrics = {
      instance_types = ["m5.large"]
      labels = {
        "agones.dev/agones-metrics" = true
      }
      taints = {
        dedicated = {
          key    = "agones.dev/agones-metrics"
          value  = true
          effect = "NO_EXECUTE"
        }
      }
      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }

  node_security_group_additional_rules = {
    ingress_gameserver_udp = {
      description      = "Agones Game Server Ports"
      protocol         = "udp"
      from_port        = local.gameserver_minport
      to_port          = local.gameserver_maxport
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
    ingress_gameserver_webhook = {
      description                   = "Cluster API to node 8081/tcp agones webhook"
      protocol                      = "tcp"
      from_port                     = 8081
      to_port                       = 8081
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  tags = local.tags
}

################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.7"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # EKS Add-Ons
  eks_addons = {
    coredns    = {}
    vpc-cni    = {}
    kube-proxy = {}
  }

  # Add-ons
  enable_metrics_server     = true
  enable_cluster_autoscaler = true

  helm_releases = {
    agones = {
      description      = "A Helm chart for Agones game server"
      namespace        = "agones-system"
      create_namespace = true
      chart            = "agones"
      chart_version    = "1.32.0"
      repository       = "https://agones.dev/chart/stable"
      values = [
        templatefile("${path.module}/helm_values/agones-values.yaml", {
          expose_udp         = true
          gameserver_minport = local.gameserver_minport
          gameserver_maxport = local.gameserver_maxport
        })
      ]
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
  # NOTE: Agones requires a Node group in Public Subnets and enable Public IP
  map_public_ip_on_launch = true

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
