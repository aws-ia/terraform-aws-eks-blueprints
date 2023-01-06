provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  cluster_version = "1.24"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.5"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      # See issue https://github.com/awslabs/amazon-eks-ami/issues/844
      pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        set -ex

        # https://docs.aws.amazon.com/eks/latest/userguide/choosing-instance-type.html#determine-max-pods
        MAX_PODS=$(/etc/eks/max-pods-calculator.sh --instance-type-from-imds \
          --cni-version ${trimprefix(data.aws_eks_addon_version.latest["vpc-cni"].version, "v")} \
          --cni-prefix-delegation-enabled)

        # These settings opt out of the default behavior and use the maximum number of pods, with a cap of 110 due to
        # Kubernetes guidance https://kubernetes.io/docs/setup/best-practices/cluster-large/
        # See more info here https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
        cat <<-EOF > /etc/profile.d/bootstrap.sh
          export USE_MAX_PODS=false
          export KUBELET_EXTRA_ARGS="--max-pods=$${MAX_PODS}"
        EOF
        # Source extra environment variables in bootstrap script
        sed -i '/^set -o errexit/a\\nsource /etc/profile.d/bootstrap.sh' /etc/eks/bootstrap.sh
      EOT
    }
  }

  tags = module.tags.tags
}

data "aws_eks_addon_version" "latest" {
  for_each = toset(["vpc-cni"])

  addon_name         = each.value
  kubernetes_version = local.cluster_version
  most_recent        = true
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

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
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
