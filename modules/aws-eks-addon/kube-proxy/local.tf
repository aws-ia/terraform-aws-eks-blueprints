
locals {
  default_eks_addon_kube_proxy_config = {
    addon_name               = "kube-proxy"
    addon_version            = "v1.21.2-eksbuild.2"
    service_account          = "kube-proxy"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }
  eks_addon_kube_proxy_config = merge(
    local.default_eks_addon_kube_proxy_config,
    var.eks_addon_kube_proxy_config
  )
}
