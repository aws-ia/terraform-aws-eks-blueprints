provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
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
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  tenant      = var.tenant      # AWS account name or unique id for tenant
  environment = var.environment # Environment area eg., preprod or prod
  zone        = var.zone        # Environment with in one sub_tenant or business unit
  region      = "us-west-2"

  vpc_cidr     = "10.0.0.0/16"
  vpc_name     = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.0.1"
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

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

#---------------------------------------------------------------
# Example to consume eks_blueprints module
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  cluster_version = "1.22"

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

module "eks_blueprints_kubernetes_addons" {
  source         = "../../../modules/kubernetes-addons"
  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  #K8s Add-ons
  enable_metrics_server     = true
  enable_cluster_autoscaler = true

  #---------------------------------------
  # PROMETHEUS and Amazon Prometheus Config
  #---------------------------------------
  # Amazon Prometheus Configuration to integrate with Prometheus Server Add-on
  enable_amazon_prometheus             = true
  amazon_prometheus_workspace_endpoint = module.eks_blueprints.amazon_prometheus_workspace_endpoint

  #---------------------------------------
  # COMMUNITY PROMETHEUS ENABLE
  #---------------------------------------
  enable_prometheus = true
  # Optional Map value
  prometheus_helm_config = {
    name       = "prometheus"                                         # (Required) Release name.
    repository = "https://prometheus-community.github.io/helm-charts" # (Optional) Repository URL where to locate the requested chart.
    chart      = "prometheus"                                         # (Required) Chart name to be installed.
    version    = "15.3.0"                                             # (Optional) Specify the exact chart version to install.
    namespace  = "prometheus"                                         # (Optional) The namespace to install the release into.
    values = [templatefile("${path.module}/helm_values/prometheus-values.yaml", {
      operating_system = "linux"
    })]
  }
  #---------------------------------------
  # ENABLE SPARK on K8S OPERATOR
  #---------------------------------------
  enable_spark_k8s_operator = true
  # Optional Map value
  spark_k8s_operator_helm_config = {
    name             = "spark-operator"
    chart            = "spark-operator"
    repository       = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
    version          = "1.1.19"
    namespace        = "spark-operator"
    timeout          = "300"
    create_namespace = true
    values           = [templatefile("${path.module}/helm_values/spark-k8s-operator-values.yaml", {})]
  }
  #---------------------------------------
  # Apache YuniKorn K8s Spark Scheduler
  #---------------------------------------
  enable_yunikorn = true
  yunikorn_helm_config = {
    name       = "yunikorn"                                  # (Required) Release name.
    repository = "https://apache.github.io/yunikorn-release" # (Optional) Repository URL where to locate the requested chart.
    chart      = "yunikorn"                                  # (Required) Chart name to be installed.
    version    = "0.12.2"                                    # (Optional) Specify the exact chart version to install.
    values     = [templatefile("${path.module}/helm_values/yunikorn-values.yaml", {})]
  }

  depends_on = [module.eks_blueprints.managed_node_groups]
}
