module "helm_addon" {
  source      = "../helm_addon"
  helm_config = local.helm_config
  irsa_config = local.irsa_config
  cluster_id  = var.eks_cluster_id
}