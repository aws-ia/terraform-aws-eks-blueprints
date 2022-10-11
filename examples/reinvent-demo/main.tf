#region Provider
###############################################################################
## Providers
###############################################################################
provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}
#endregion

#region Data
###############################################################################
## Data
###############################################################################
data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.eks_cluster_id
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_addon_version" "latest" {
  for_each = toset(["kube-proxy", "vpc-cni"])

  addon_name         = each.value
  kubernetes_version = module.eks_cluster.eks_cluster_version
  most_recent        = true
}
#endregion

#region Locals
###############################################################################
## Locals
###############################################################################
locals {
  name   = basename(path.cwd)
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

  sample_app_namespace = "app-2048"
}
#endregion

#region EKS Cluster
###############################################################################
## EKS Cluster Provisioning
###############################################################################
module "eks_cluster" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  cluster_name    = local.name
  cluster_version = "1.23"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.large"]
      min_size        = 3
      max_size        = 3
      desired_size    = 3
      subnet_ids      = module.vpc.private_subnets
    }
  }

  fargate_profiles = {
    alb_sample_app = {
      fargate_profile_name = "app-2048"
      fargate_profile_namespaces = [
        {
          namespace = local.sample_app_namespace
      }]
      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = local.tags
}
#endregion

#region AddOns
###############################################################################
## Kubernetes AddOns
###############################################################################
module "addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"

  eks_cluster_id       = module.eks_cluster.eks_cluster_id
  eks_cluster_endpoint = module.eks_cluster.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_cluster.oidc_provider
  eks_cluster_version  = module.eks_cluster.eks_cluster_version

  # Wait on the `kube-system` profile before provisioning addons
  data_plane_wait_arn = module.eks_cluster.managed_node_group_arn[0]

  enable_amazon_eks_vpc_cni = true
  amazon_eks_vpc_cni_config = {
    addon_version     = data.aws_eks_addon_version.latest["vpc-cni"].version
    resolve_conflicts = "OVERWRITE"
  }

  enable_amazon_eks_kube_proxy = true
  amazon_eks_kube_proxy_config = {
    addon_version     = data.aws_eks_addon_version.latest["kube-proxy"].version
    resolve_conflicts = "OVERWRITE"
  }
  enable_aws_load_balancer_controller = true
  enable_aws_for_fluentbit            = true
  enable_aws_cloudwatch_metrics       = true
  enable_fargate_fluentbit            = true

  # Sample application
  enable_app_2048 = true

  tags = local.tags
}
#endregion

#region VPC
###############################################################################
## VPC
###############################################################################
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
#endregion

#region Outputs
###############################################################################
## Outputs
###############################################################################
output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_cluster.configure_kubectl
}
#endregion
