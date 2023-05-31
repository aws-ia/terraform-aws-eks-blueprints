provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks_cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.eks_cluster_id]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.eks_cluster_id]
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.eks_cluster_id
}

module "eks_cluster" {
  source = "../modules/eks_cluster"

  aws_region      = var.aws_region
  service_name    = "blue"
  cluster_version = "1.24"

  argocd_route53_weight      = "100"
  route53_weight             = "100"
  ecsfrontend_route53_weight = "100"

  environment_name       = var.environment_name
  hosted_zone_name       = var.hosted_zone_name
  eks_admin_role_name    = var.eks_admin_role_name
  workload_repo_url      = var.workload_repo_url
  workload_repo_secret   = var.workload_repo_secret
  workload_repo_revision = var.workload_repo_revision
  workload_repo_path     = var.workload_repo_path

  addons_repo_url = var.addons_repo_url

  iam_platform_user                 = var.iam_platform_user
  argocd_secret_manager_name_suffix = var.argocd_secret_manager_name_suffix
}
