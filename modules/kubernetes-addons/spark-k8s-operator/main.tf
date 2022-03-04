module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  set_values        = local.set_values
  addon_context     = var.addon_context
  depends_on = [
    module.spark-irsa,
    module.spark-operator-irsa
  ]
}

module "spark-irsa" {
  source                            = "../../irsa"
  create_kubernetes_namespace       = true
  create_kubernetes_service_account = true
  kubernetes_namespace              = local.helm_config["namespace"]
  kubernetes_service_account        = local.spark_service_account_name
  irsa_iam_policies                 = var.spark_irsa_policies
  irsa_iam_permissions_boundary     = var.spark_irsa_permissions_boundary
  addon_context                     = var.addon_context
}

module "spark-operator-irsa" {
  source                            = "../../irsa"
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = true
  kubernetes_namespace              = local.helm_config["namespace"]
  kubernetes_service_account        = local.spark_operator_service_account_name
  irsa_iam_policies                 = var.spark_operator_irsa_policies
  irsa_iam_permissions_boundary     = var.spark_operator_irsa_permissions_boundary
  addon_context                     = var.addon_context
}