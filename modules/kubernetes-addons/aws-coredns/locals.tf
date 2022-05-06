
locals {
  default_addon_config = {
    addon_name               = "coredns"
    service_account          = "coredns"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = ""
    additional_iam_policies  = []
    preserve                 = true
    tags                     = {}
  }

  addon_config = merge(
    local.default_addon_config,
    var.addon_config
  )
}
