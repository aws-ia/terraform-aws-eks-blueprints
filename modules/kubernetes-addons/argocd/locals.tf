locals {
  default_helm_values = [templatefile("${path.module}/values.yaml", {})]

  name      = "argo-cd"
  namespace = "argocd"

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://argoproj.github.io/argo-helm"
    version          = "4.9.14"
    namespace        = local.namespace
    timeout          = 1200
    create_namespace = true
    values           = local.default_helm_values
    description      = "The ArgoCD Helm Chart deployment configuration"
    wait             = false
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_argocd_application = {
    namespace          = local.helm_config["namespace"]
    target_revision    = "HEAD"
    destination        = "https://kubernetes.default.svc"
    project            = "default"
    values             = {}
    type               = "helm"
    add_on_application = false
  }

  global_application_values = {
    region      = var.addon_context.aws_region_name
    account     = var.addon_context.aws_caller_identity_account_id
    clusterName = var.addon_context.eks_cluster_id
  }

}
