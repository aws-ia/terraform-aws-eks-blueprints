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
data "aws_caller_identity" "current" {}

locals {
  name   = "mwaa"
  region = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  dag_s3_path = "dags"

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

  # https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/485
  # https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/494
  cluster_kms_key_additional_admin_arns = [data.aws_caller_identity.current.arn]

  # Add MWAA IAM Role to aws-auth configmap
  map_roles = [
    {
      rolearn  = module.mwaa.mwaa_role_arn
      username = "mwaa-role"
      groups   = ["system:masters"]
    }
  ]

  managed_node_groups = {
    mg5 = {
      node_group_name = "mg5"
      instance_types  = ["m5.large"]
      min_size        = "2"
      disk_size       = 100
    }
  }

  tags = local.tags
}

#------------------------------------------------------------------------
# Kubernetes Add-on Module
#------------------------------------------------------------------------

module "eks_blueprints_kubernetes_addons" {
  source = "../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  enable_metrics_server     = true
  enable_cluster_autoscaler = true

  tags = local.tags
}

#------------------------------------------------------------------------
# AWS MWAA Module
#------------------------------------------------------------------------

module "mwaa" {
  source  = "aws-ia/mwaa/aws"
  version = "0.0.1"

  name                  = "basic-mwaa"
  airflow_version       = "2.2.2"
  environment_class     = "mw1.medium"  # mw1.small / mw1.medium / mw1.large
  webserver_access_mode = "PUBLIC_ONLY" # Default PRIVATE_ONLY for production environments

  create_s3_bucket  = false
  source_bucket_arn = module.s3_bucket.s3_bucket_arn

  dag_s3_path          = local.dag_s3_path
  requirements_s3_path = "${local.dag_s3_path}/requirements.txt"

  min_workers = 1
  max_workers = 25

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = slice(module.vpc.private_subnets, 0, 2) # Required 2 subnets only
  source_cidr        = [module.vpc.vpc_cidr_block]             # Add your IP here to access Airflow UI

  airflow_configuration_options = {
    "core.load_default_connections" = "false"
    "core.load_examples"            = "false"
    "webserver.dag_default_view"    = "tree"
    "webserver.dag_orientation"     = "TB"
    "logging.logging_level"         = "INFO"
  }

  logging_configuration = {
    dag_processing_logs = {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs = {
      enabled   = true
      log_level = "INFO"
    }

    task_logs = {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs = {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs = {
      enabled   = true
      log_level = "INFO"
    }
  }

  tags = local.tags
}

#------------------------------------------------------------------------
# Create K8s Namespace and Role
#------------------------------------------------------------------------

resource "kubernetes_namespace_v1" "mwaa" {
  metadata {
    name = "mwaa"
  }
}

resource "kubernetes_role_v1" "mwaa" {
  metadata {
    name      = "mwaa-role"
    namespace = kubernetes_namespace_v1.mwaa.metadata[0].name
  }

  rule {
    api_groups = [
      "",
      "apps",
      "batch",
      "extensions",
    ]
    resources = [
      "jobs",
      "pods",
      "pods/attach",
      "pods/exec",
      "pods/log",
      "pods/portforward",
      "secrets",
      "services",
    ]
    verbs = [
      "create",
      "delete",
      "describe",
      "get",
      "list",
      "patch",
      "update",
    ]
  }
}

resource "kubernetes_role_binding_v1" "mwaa" {
  metadata {
    name      = "mwaa-role-binding"
    namespace = kubernetes_namespace_v1.mwaa.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_namespace_v1.mwaa.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = "mwaa-service"
    api_group = "rbac.authorization.k8s.io"
  }
}

#------------------------------------------------------------------------
# Dags and Requirements
#------------------------------------------------------------------------

#tfsec:ignore:*
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "mwaa-${random_id.this.hex}"
  acl    = "private"

  # For example only - please evaluate for your environment
  force_destroy = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}

# Kubeconfig is required for KubernetesPodOperator
# https://airflow.apache.org/docs/apache-airflow-providers-cncf-kubernetes/stable/operators.html
locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "mwaa"
    clusters = [{
      name = module.eks_blueprints.eks_cluster_arn
      cluster = {
        certificate-authority-data = module.eks_blueprints.eks_cluster_certificate_authority_data
        server                     = module.eks_blueprints.eks_cluster_endpoint
      }
    }]
    contexts = [{
      name = "mwaa" # must match KubernetesPodOperator context
      context = {
        cluster = module.eks_blueprints.eks_cluster_arn
        user    = "mwaa"
      }
    }]
    users = [{
      name = "mwaa"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })
}

resource "aws_s3_bucket_object" "kube_config" {
  bucket  = module.s3_bucket.s3_bucket_id
  key     = "${local.dag_s3_path}/kube_config.yaml"
  content = local.kubeconfig
  etag    = md5(local.kubeconfig)
}

resource "aws_s3_bucket_object" "uploads" {
  for_each = fileset("${local.dag_s3_path}/", "*")

  bucket = module.s3_bucket.s3_bucket_id
  key    = "${local.dag_s3_path}/${each.value}"
  source = "${local.dag_s3_path}/${each.value}"
  etag   = filemd5("${local.dag_s3_path}/${each.value}")
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
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}

resource "random_id" "this" {
  byte_length = "2"
}
