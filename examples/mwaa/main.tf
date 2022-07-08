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
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

#------------------------------------------------------------------------
# Local Variables
#------------------------------------------------------------------------
locals {
  name     = var.name
  region   = var.region
  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = merge(var.tags, {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  })

  terraform_version = "Terraform v1.0.1"

  # Amazon MWAA (Apache Airflow)
  mwaa_name             = "basic-mwaa"
  airflow_version       = "2.2.2"
  environment_class     = "mw1.medium" # mw1.small / mw1.medium / mw1.large
  dag_s3_path           = "dags"
  requirements_s3_path  = "dags/requirements.txt"
  source_cidr           = ["10.0.0.0/16"] #Add your IP here to access Airflow UI
  min_workers           = 1
  max_workers           = 25
  webserver_access_mode = "PUBLIC_ONLY" # Default PRIVATE_ONLY for production environments


  # Airflow configuration
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

}

#------------------------------------------------------------------------
# AWS VPC Module
#------------------------------------------------------------------------
module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }
}

#------------------------------------------------------------------------
# AWS EKS Blueprints Module
#------------------------------------------------------------------------
module "eks_blueprints" {
  source = "../.."

  cluster_name       = local.name
  cluster_version    = var.eks_cluster_version
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # Attach additional security group ids to Worker Security group ID
  worker_additional_security_group_ids = [] # Optional


  # Add MWAA IAM Role to aws-auth configmap
  map_roles = [
    {
      rolearn  = "${module.mwaa.mwaa_role_arn}" # The ARN of the IAM role
      username = "mwaa-role"                    # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"]             # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ]

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    # Managed Node groups with minimum config
    mg5 = {
      node_group_name = "mg5"
      instance_types  = ["m5.large"]
      min_size        = "2"
      disk_size       = 100 # Disk size is used only with Managed Node Groups without Launch Templates
    }
  }
}

#------------------------------------------------------------------------
# Kubernetes Add-on Module
#------------------------------------------------------------------------
module "eks_blueprints_kubernetes_addons" {
  source = "../../modules/kubernetes-addons"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  enable_metrics_server     = false
  enable_cluster_autoscaler = false

}

#------------------------------------------------------------------------
# AWS MWAA Module
#------------------------------------------------------------------------

module "mwaa" {
  source                        = "aws-ia/mwaa/aws"
  version                       = "0.0.1"
  name                          = local.mwaa_name
  airflow_version               = local.airflow_version
  environment_class             = local.environment_class
  dag_s3_path                   = local.dag_s3_path
  requirements_s3_path          = local.requirements_s3_path
  logging_configuration         = local.logging_configuration
  airflow_configuration_options = local.airflow_configuration_options
  min_workers                   = local.min_workers
  max_workers                   = local.max_workers
  vpc_id                        = module.aws_vpc.vpc_id
  private_subnet_ids            = [module.aws_vpc.private_subnets[0], module.aws_vpc.private_subnets[1]]
  webserver_access_mode         = local.webserver_access_mode
  source_cidr                   = local.source_cidr
}

#------------------------------------------------------------------------
# Create the kubeconfig
#------------------------------------------------------------------------

resource "null_resource" "create-kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${local.region} --kubeconfig ./dags/kube_config.yaml --name ${local.name} --alias aws"
  }
}

#------------------------------------------------------------------------
# associate-iam-oidc-provider
#------------------------------------------------------------------------

resource "null_resource" "associate-iam-oidc-provider" {
  provisioner "local-exec" {
    command = "eksctl utils associate-iam-oidc-provider --region ${local.region} --cluster ${local.name} --approve"
  }
}


#------------------------------------------------------------------------
# Create Namespace mwaa
#------------------------------------------------------------------------
resource "kubernetes_namespace" "mwaa" {
  metadata {
    name = "mwaa"
  }
}

#------------------------------------------------------------------------
# Create Role
#------------------------------------------------------------------------

resource "kubernetes_role" "mwaa_role" {
  metadata {
    name      = "mwaa-role"
    namespace = "mwaa"
  }

  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources  = ["jobs", "pods", "pods/attach", "pods/exec", "pods/log", "pods/portforward", "secrets", "services"]
    verbs      = ["create", "delete", "describe", "get", "list", "patch", "update"]
  }
}

resource "kubernetes_role_binding" "mwaa_role_binding" {
  metadata {
    name      = "mwaa-role-binding"
    namespace = "mwaa"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "mwaa-role"
  }
  subject {
    kind      = "User"
    name      = "mwaa-service"
    api_group = "rbac.authorization.k8s.io"
  }
}

#------------------------------------------------------------------------
# create iamidentitymapping
#------------------------------------------------------------------------

resource "null_resource" "iam-identity-mapping" {
  provisioner "local-exec" {
    command = "eksctl create iamidentitymapping --region ${local.region} --cluster ${local.name} --arn arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/mwaa-executor-${local.name}-${local.region} --username mwaa-service"
  }
}

#------------------------------------------------------------------------
# Sync Dags
#------------------------------------------------------------------------

resource "null_resource" "sync-dags" {
  provisioner "local-exec" {
    command = "aws s3 sync dags s3://${module.mwaa.aws_s3_bucket_name}/dags --exclude '__pycache__/*' --region ${local.region}"
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}

#------------------------------------------------------------------------
# Sync Requirements
#------------------------------------------------------------------------

resource "null_resource" "sync-requirements" {
  provisioner "local-exec" {
    command = "aws s3 cp ./dags/requirements.txt s3://${module.mwaa.aws_s3_bucket_name}/${local.requirements_s3_path} --region ${local.region}"
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}