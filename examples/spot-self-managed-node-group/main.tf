provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "../.."

  cluster_name    = local.name
  cluster_version = "1.23"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  self_managed_node_groups = {
    on_demand = {
      name = "on-demand"

      instance_types = ["m5.large"]
    }

    spot_2vcpu_8mem = {
      name = "spot-2vcpu-8mem"

      min_size = 0

      capacity_rebalance         = true
      use_mixed_instances_policy = true
      mixed_instances_policy = {
        override = [
          { instance_type = "m5.large" },
          { instance_type = "m4.large" },
          { instance_type = "m6a.large" },
          { instance_type = "m5a.large" },
          { instance_type = "m5d.large" },
        ]
      }

      autoscaling_group_tags = {
        "k8s.io/cluster-autoscaler/enabled"                              = "TRUE"
        "k8s.io/cluster-autoscaler/migrate"                              = "owned"
        "k8s.io/cluster-autoscaler/node-template/label/eks/capacityType" = "spot"
        "k8s.io/cluster-autoscaler/node-template/label/eks/nodegroup"    = "spot-2vcpu-8mem"
      }
    }

    spot_4vcpu_16mem = {
      name = "spot-4vcpu-16mem"

      min_size = 0

      capacity_rebalance         = true
      use_mixed_instances_policy = true
      mixed_instances_policy = {
        override = [
          { instance_type = "m5.xlarge" },
          { instance_type = "m4.xlarge" },
          { instance_type = "m6a.xlarge" },
          { instance_type = "m5a.xlarge" },
          { instance_type = "m5d.xlarge" },
        ]
      }

      autoscaling_group_tags = {
        "k8s.io/cluster-autoscaler/enabled"                              = "TRUE"
        "k8s.io/cluster-autoscaler/migrate"                              = "owned"
        "k8s.io/cluster-autoscaler/node-template/label/eks/capacityType" = "spot"
        "k8s.io/cluster-autoscaler/node-template/label/eks/nodegroup"    = "spot-4vcpu-16mem"
      }
    }
  }
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  enable_metrics_server               = true
  enable_aws_node_termination_handler = true
  auto_scaling_group_names            = module.eks_blueprints.self_managed_node_groups_autoscaling_group_names

  enable_cluster_autoscaler = true
  cluster_autoscaler_helm_config = {
    set = [
      {
        name  = "extraArgs.expander"
        value = "priority"
      },
      {
        name  = "expanderPriorities"
        value = <<-EOT
          100:
            - .*-spot-2vcpu-8mem.*
          90:
            - .*-spot-4vcpu-16mem.*
          10:
            - .*
        EOT
      }
    ]
  }
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}
