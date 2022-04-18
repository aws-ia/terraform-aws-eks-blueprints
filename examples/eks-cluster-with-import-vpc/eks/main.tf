provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.cluster_id]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks_blueprints.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.cluster_id]
  }
}

data "aws_availability_zones" "available" {}

#---------------------------------------------------------------
# Terraform VPC remote state import from S3
#---------------------------------------------------------------
data "terraform_remote_state" "vpc_s3_backend" {
  backend = "s3"
  config = {
    bucket = var.tf_state_vpc_s3_bucket
    key    = var.tf_state_vpc_s3_key
    region = local.region
  }
}

locals {
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  region      = "us-west-2"

  terraform_version = "Terraform v1.0.1"

  vpc_id             = data.terraform_remote_state.vpc_s3_backend.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc_s3_backend.outputs.private_subnets
  public_subnet_ids  = data.terraform_remote_state.vpc_s3_backend.outputs.public_subnets
}

module "eks_blueprints" {
  source = "../../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnets
  vpc_id             = local.vpc_id
  private_subnet_ids = local.private_subnet_ids

  # EKS CONTROL PLANE VARIABLES
  cluster_version = "1.22"

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.xlarge"]
      subnet_ids      = local.private_subnet_ids
    }
  }
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id               = module.eks-blueprints.eks_cluster_id
  eks_worker_security_group_id = module.eks-blueprints.worker_node_security_group_id

  # EKS Managed Add-ons
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_amazon_eks_aws_ebs_csi_driver = true

  #K8s Add-ons
  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
  enable_cluster_autoscaler           = true
  enable_vpa                          = true
  enable_prometheus                   = true
  enable_ingress_nginx                = true
  enable_aws_for_fluentbit            = true
  enable_aws_cloudwatch_metrics       = true
  enable_argocd                       = true
  enable_fargate_fluentbit            = false
  enable_argo_rollouts                = true
  enable_kubernetes_dashboard         = true
  enable_yunikorn                     = true

  depends_on = [module.eks-blueprints.managed_node_groups]
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks-blueprints.configure_kubectl
}
