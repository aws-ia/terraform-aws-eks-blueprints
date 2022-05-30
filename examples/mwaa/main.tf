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
data "aws_caller_identity" "current" {}

#------------------------------------------------------------------------
# Local Variables
#------------------------------------------------------------------------
locals {
  tenant      = var.tenant      # AWS account name or unique id for tenant
  environment = var.environment # Environment area eg., preprod or prod
  zone        = var.zone        # Evironment with in one sub_tenant or business unit
  region      = "us-west-2"

  vpc_cidr                = "10.0.0.0/16"
  vpc_name                = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  count_availability_zone = (length(data.aws_availability_zones.available.names) <= 3) ? length(data.aws_availability_zones.available.zone_ids) : 3
  azs                     = slice(data.aws_availability_zones.available.names, 0, local.count_availability_zone)
  cluster_name            = join("-", [local.tenant, local.environment, local.zone, "eks"])
  cluster_version         = "1.21"

  terraform_version = "Terraform v1.0.1"

  # Amazon MWAA (Apache Airflow)
  environment_name      = join("-", [local.tenant, local.environment, local.zone, "mwaa"])
  airflow_version       = "2.2.2"
  environment_class     = "mw1.medium" # mw1.small / mw1.medium / mw1.large
  airflow_min_workers   = 1
  airflow_max_workers   = 25
  dag_s3_path           = "dags"
  plugins_s3_path       = "plugins.zip"
  requirements_s3_path  = "dags/requirements.txt"
  webserver_access_mode = "PUBLIC_ONLY"
  vpn_cidr              = ["10.0.0.0/16"] #Add your IP here to access Airflow UI


  # Airflow configuration
  airflow_configuration_options = {
    "core.default_task_retries"         = 3
    "celery.worker_autoscale"           = "5,5"
    "core.check_slas"                   = "false"
    "core.dag_concurrency"              = 96
    "core.dag_file_processor_timeout"   = 600
    "core.dagbag_import_timeout"        = 600
    "core.max_active_runs_per_dag"      = 32
    "core.parallelism"                  = 64
    "scheduler.processor_poll_interval" = 15
    log_level                           = "INFO"
    dag_timeout                         = 480
    "webserver_timeout" = {
      master = 480
      worker = 480
    }
  }

  logging_configuration = {
    "dag_processing_logs" = {
      enabled   = true
      log_level = "INFO"
    }

    "scheduler_logs" = {
      enabled   = true
      log_level = "INFO"
    }

    "task_logs" = {
      enabled   = true
      log_level = "INFO"
    }

    "webserver_logs" = {
      enabled   = true
      log_level = "INFO"
    }

    "worker_logs" = {
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

#------------------------------------------------------------------------
# AWS EKS Blueprints Module
#------------------------------------------------------------------------
module "eks_blueprints" {
  source = "../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # Attach additional security group ids to Worker Security group ID
  worker_additional_security_group_ids = [] # Optional

  # EKS CONTROL PLANE VARIABLES
  cluster_version = local.cluster_version

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

  enable_metrics_server     = true
  enable_cluster_autoscaler = true

}

#------------------------------------------------------------------------
# AWS MWAA Module
#------------------------------------------------------------------------

module "mwaa" {
  source                        = "../../modules/aws-mwaa"
  environment_name              = local.environment_name
  airflow_version               = local.airflow_version
  environment_class             = local.environment_class
  dag_s3_path                   = local.dag_s3_path
  plugins_s3_path               = local.plugins_s3_path
  requirements_s3_path          = local.requirements_s3_path
  logging_configuration         = local.logging_configuration
  airflow_configuration_options = local.airflow_configuration_options
  min_workers                   = local.airflow_min_workers
  max_workers                   = local.airflow_max_workers
  vpc_id                        = module.aws_vpc.vpc_id
  private_subnet_ids            = [module.aws_vpc.private_subnets[0], module.aws_vpc.private_subnets[1]]
  webserver_access_mode         = local.webserver_access_mode
  vpn_cidr = local.vpn_cidr
}

#------------------------------------------------------------------------
# Create the kubeconfig
#------------------------------------------------------------------------

resource "null_resource" "create-kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${local.region} --kubeconfig ./dags/kube_config.yaml --name ${local.cluster_name} --alias aws"
  }
}

#------------------------------------------------------------------------
# associate-iam-oidc-provider
#------------------------------------------------------------------------

resource "null_resource" "associate-iam-oidc-provider" {
  provisioner "local-exec" {
    command = "eksctl utils associate-iam-oidc-provider --region ${local.region} --cluster ${local.cluster_name} --approve"
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

resource "null_resource" "create-role" {
  provisioner "local-exec" {
    command = "export KUBECONFIG=./dags/kube_config.yaml | kubectl apply -f ./roles.yaml -n mwaa"
  }
}

#------------------------------------------------------------------------
# create iamidentitymapping
#------------------------------------------------------------------------

resource "null_resource" "iam-identity-mapping" {
  provisioner "local-exec" {
    command = "eksctl create iamidentitymapping --region ${local.region} --cluster ${local.cluster_name} --arn arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/mwaa-executor-${local.cluster_name}-${local.region} --username mwaa-service"
  }
}

#------------------------------------------------------------------------
# Sync Dags
#------------------------------------------------------------------------

resource "null_resource" "sync-dags" {
  provisioner "local-exec" {
    command = "aws s3 sync dags s3://${module.mwaa.aws_s3_bucket}/dags --exclude '__pycache__/*' --region ${local.region}"
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
    command = "aws s3 cp ./dags/requirements.txt s3://${module.mwaa.aws_s3_bucket}/${local.requirements_s3_path} --region ${local.region}"
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}
