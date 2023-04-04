provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks_cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.eks_cluster_id
}

module "eks_cluster" {
  source = "../modules/eks_cluster"

  suffix_stack_name = "green"
  cluster_version   = "1.24" # Here, we deploy the cluster with the N+1 Kubernetes Version

  argocd_route53_weight      = "0" # We control with theses parameters how we send traffic to the workloads in the new cluster
  route53_weight             = "0"
  ecsfrontend_route53_weight = "0"

  core_stack_name        = var.core_stack_name
  hosted_zone_name       = var.hosted_zone_name
  eks_admin_role_name    = var.eks_admin_role_name
  workload_repo_url      = var.workload_repo_url
  workload_repo_secret   = var.workload_repo_secret
  workload_repo_revision = var.workload_repo_revision
  workload_repo_path     = var.workload_repo_path

  addons_repo_url = var.addons_repo_url

  iam_platform_user                 = var.iam_platform_user
  argocd_secret_manager_name_suffix = var.argocd_secret_manager_name_suffix
  vpc_tag_key                       = var.vpc_tag_key
  vpc_tag_value                     = var.vpc_tag_value

}
