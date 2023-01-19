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
# VPC CNI Metrics
################################################################################

module "vpc_cni_metrics_addon" {
  source = "github.com/aws-ia/terraform-aws-eks-addon"

  name             = "cni-metrics-helper"
  chart            = "cni-metrics-helper"
  repository       = "https://aws.github.io/eks-charts"
  description      = "A Helm chart for the AWS VPC CNI Metrics Helper"
  namespace        = "kube-system"
  create_namespace = false

  # Get corresponding region, account, and domain https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  # The image url is composed as <account>.dkr.ecr.<region>.<domain>/cni-metrics-helper:<tag>
  values = [
    <<-EOT
      image:
        region: us-west-2
        tag: v1.12.1
        account: "602401143452"
        domain: "amazonaws.com"
      env:
        AWS_VPC_K8S_CNI_LOGLEVEL: ERROR
      serviceAccount:
        name: cni-metrics-helper
    EOT
  ]

  set_irsa_name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  # # Equivalent to the following but the ARN is only known internally to the module
  # set = [{
  #   name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #   value = iam_role_arn.this[0].arn
  # }]

  # IAM role for service account (IRSA)
  create_role = true
  role_policy_arns = {
    cni_metrics = aws_iam_policy.cni_metrics.arn
  }

  oidc_providers = {
    this = {
      provider_arn = module.eks.oidc_provider_arn
      # namespace is inherited from chart
      service_account = "cni-metrics-helper"
    }
  }

  tags = local.tags
}

resource "aws_iam_policy" "cni_metrics" {
  name        = "${module.eks.cluster_name}-cni-metrics"
  description = "IAM policy for EKS CNI Metrics helper"
  path        = "/"
  policy      = data.aws_iam_policy_document.cni_metrics.json

  tags = local.tags
}

data "aws_iam_policy_document" "cni_metrics" {
  statement {
    sid = "CNIMetrics"
    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
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

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  node_security_group_additional_rules = {
    # Allows Control Plane Nodes to talk to Worker nodes vpc cni metrics port
    vpc_cni_metrics_traffic = {
      description                   = "Cluster API to Nodegroup vpc cni metrics"
      protocol                      = "tcp"
      from_port                     = 61678
      to_port                       = 61678
      type                          = "ingress"
      source_cluster_security_group = true
    }
  } 

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 1
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
