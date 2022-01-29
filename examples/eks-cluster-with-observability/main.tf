terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.73.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.13.3"
    }
  }

  backend "local" {
    path = "local_tf_state/terraform-main.tfstate"
  }
}

provider "aws" {}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

locals {
  tenant      = "aws001"        # AWS account name or unique id for tenant
  environment = "preprod"       # Environment area eg., preprod or prod
  zone        = "observability" # Environment within one sub_tenant or business unit

  kubernetes_version = "1.21"

  vpc_cidr     = "10.0.0.0/16"
  vpc_name     = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.1.4"
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.11.3"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = data.aws_availability_zones.available.names

  public_subnets  = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

}

module "aws-eks-accelerator-for-terraform" {
  source = "../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  create_eks         = true
  kubernetes_version = local.kubernetes_version

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.xlarge"]
      min_size        = 3
      subnet_ids      = module.aws_vpc.private_subnets
    }
  }

  # Enable Amazon Prometheus - Creates a new Workspace id
  enable_amazon_prometheus = true
}

resource "aws_iam_policy" "fluentbit-opensearch-access" {
  name        = "fluentbit-opensearch-access"
  description = "IAM policy to allow Fluentbit access to OpenSearch"
  policy      = data.aws_iam_policy_document.fluentbit-opensearch-access.json
}

module "kubernetes-addons" {
  source         = "../../modules/kubernetes-addons"
  eks_cluster_id = module.aws-eks-accelerator-for-terraform.eks_cluster_id

  #K8s Add-ons
  enable_metrics_server     = true
  enable_cluster_autoscaler = true
  enable_argocd             = true

  # Fluentbit
  enable_aws_for_fluentbit        = true
  aws_for_fluentbit_irsa_policies = [aws_iam_policy.fluentbit-opensearch-access.arn]
  aws_for_fluentbit_helm_config = {
    aws_for_fluentbit_cw_log_group_name = "/${module.aws-eks-accelerator-for-terraform.eks_cluster_id
    }/worker-fluentbit-logs"
    values = [templatefile("${path.module}/helm_values/aws-for-fluentbit-values.yaml", {
      aws_region = data.aws_region.current.name,
      log_group_name = "/${module.aws-eks-accelerator-for-terraform.eks_cluster_id
      }/worker-fluentbit-logs",
      service_account_name = "aws=for-fluent-bit-sa",
      host                 = aws_elasticsearch_domain.opensearch.endpoint,
      match                = "*",
    })]
  }

  #---------------------------------------
  # PROMETHEUS and Amazon Prometheus Config
  #---------------------------------------
  # Amazon Prometheus Configuration to integrate with Prometheus Server Add-on
  enable_amazon_prometheus             = true
  amazon_prometheus_workspace_endpoint = module.aws-eks-accelerator-for-terraform.amazon_prometheus_workspace_endpoint

  #---------------------------------------
  # COMMUNITY PROMETHEUS ENABLE
  #---------------------------------------
  enable_prometheus = true
  # Optional Map value
  prometheus_helm_config = {
    name       = "prometheus"                                         # (Required) Release name.
    repository = "https://prometheus-community.github.io/helm-charts" # (Optional) Repository URL where to locate the requested chart.
    chart      = "prometheus"                                         # (Required) Chart name to be installed.
    version    = "15.0.4"                                             # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
    namespace  = "prometheus"                                         # (Optional) The namespace to install the release into. Defaults to default
    # values = [templatefile("${path.module}/helm_values/prometheus-values.yaml", {
    #   operating_system = "linux"
    # })]
  }
}


