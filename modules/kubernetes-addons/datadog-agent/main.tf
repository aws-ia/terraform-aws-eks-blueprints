module "helm_addon" {
  source            = "github.com/aws-samples/aws-eks-accelerator-for-terraform//modules/kubernetes-addons/helm-addon?ref=v4.6.2"
  count             = var.enable_datadog ? 1 : 0
  helm_config       = local.helm_config
  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
}