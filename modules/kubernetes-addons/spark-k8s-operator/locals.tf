locals {
  name                 = "spark-operator"
  service_account_name = "spark-operator-sa"

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
    version     = "1.1.19"
    namespace   = local.name
    description = "The spark_k8s_operator HelmChart Ingress Controller deployment configuration"
    values      = local.default_helm_values
    timeout     = "1200"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    sa-name = local.service_account_name
  })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    eks_cluster_id                    = var.addon_context.eks_cluster_id
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}