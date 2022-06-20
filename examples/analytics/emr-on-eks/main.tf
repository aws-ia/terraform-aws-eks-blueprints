provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
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
  source = "../../.."

  cluster_name    = local.name
  cluster_version = "1.22"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.xlarge"]
      min_size        = 3
      subnet_ids      = module.vpc.private_subnets
    }
  }

  #---------------------------------------
  # ENABLE EMR ON EKS
  # 1. Creates namespace
  # 2. k8s role and role binding(emr-containers user) for the above namespace
  # 3. IAM role for the team execution role
  # 4. Update AWS_AUTH config map with  emr-containers user and AWSServiceRoleForAmazonEMRContainers role
  # 5. Create a trust relationship between the job execution role and the identity of the EMR managed service account
  #---------------------------------------
  enable_emr_on_eks = true
  emr_on_eks_teams = {
    emr-team-a = {
      namespace               = "emr-data-team-a"
      job_execution_role      = "emr-eks-data-team-a"
      additional_iam_policies = [aws_iam_policy.emr_on_eks.arn]
    }
    emr-team-b = {
      namespace               = "emr-data-team-b"
      job_execution_role      = "emr-eks-data-team-b"
      additional_iam_policies = [aws_iam_policy.emr_on_eks.arn]
    }
  }
  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # Add-ons
  enable_metrics_server     = true
  enable_cluster_autoscaler = true

  enable_amazon_prometheus             = true
  amazon_prometheus_workspace_endpoint = aws_prometheus_workspace.amp.prometheus_endpoint

  enable_prometheus = true
  prometheus_helm_config = {
    name       = "prometheus"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "prometheus"
    version    = "15.3.0"
    namespace  = "prometheus"
    values = [templatefile("${path.module}/helm_values/prometheus-values.yaml", {
      operating_system = "linux"
    })]
  }

  enable_vpa = true
  vpa_helm_config = {
    name       = "vpa"
    repository = "https://charts.fairwinds.com/stable"
    chart      = "vpa"
    version    = "1.0.0"
    namespace  = "vpa"
    values     = [templatefile("${path.module}/helm_values/vpa-values.yaml", {})]
  }

  tags = local.tags
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

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

#---------------------------------------------------------------
# Example IAM policies for EMR job execution
#---------------------------------------------------------------
data "aws_iam_policy_document" "emr_on_eks" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:s3:::*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:*"]

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }
}

resource "aws_iam_policy" "emr_on_eks" {
  name        = format("%s-%s", local.name, "emr-job-iam-policies")
  description = "IAM policy for EMR on EKS Job execution"
  path        = "/"
  policy      = data.aws_iam_policy_document.emr_on_eks.json
}

#---------------------------------------------------------------
# Amazon Prometheus Workspace
#---------------------------------------------------------------
resource "aws_prometheus_workspace" "amp" {
  alias = format("%s-%s", "amp-ws", local.name)

  tags = local.tags
}
