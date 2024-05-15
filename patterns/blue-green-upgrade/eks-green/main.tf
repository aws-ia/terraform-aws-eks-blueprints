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

module "eks_cluster" {
  source = "../modules/eks_cluster"

  aws_region      = var.aws_region
  service_name    = "green"
  cluster_version = "1.27" # Here, we deploy the cluster with the N+1 Kubernetes Version

  argocd_route53_weight      = "0" # We control with theses parameters how we send traffic to the workloads in the new cluster
  route53_weight             = "0"
  ecsfrontend_route53_weight = "0"

  environment_name    = var.environment_name
  hosted_zone_name    = var.hosted_zone_name
  eks_admin_role_name = var.eks_admin_role_name

  aws_secret_manager_git_private_ssh_key_name = var.aws_secret_manager_git_private_ssh_key_name
  argocd_secret_manager_name_suffix           = var.argocd_secret_manager_name_suffix
  ingress_type                                = var.ingress_type

  gitops_addons_org      = var.gitops_addons_org
  gitops_addons_repo     = var.gitops_addons_repo
  gitops_addons_basepath = var.gitops_addons_basepath
  gitops_addons_path     = var.gitops_addons_path
  gitops_addons_revision = var.gitops_addons_revision

  gitops_workloads_org      = var.gitops_workloads_org
  gitops_workloads_repo     = var.gitops_workloads_repo
  gitops_workloads_revision = var.gitops_workloads_revision
  gitops_workloads_path     = var.gitops_workloads_path

}
