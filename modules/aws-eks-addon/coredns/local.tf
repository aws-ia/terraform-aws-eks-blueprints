
locals {
  default_eks_addon_coredns_config = {
    addon_name               = "coredns"
    addon_version            = "v1.8.4-eksbuild.1"
    service_account          = "coredns"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = ""
    additional_iam_policies  = []
    tags                     = {}
  }
  eks_addon_coredns_config = merge(
    local.default_eks_addon_coredns_config,
    var.eks_addon_coredns_config
  )
}
