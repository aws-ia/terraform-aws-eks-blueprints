
locals {
  default_addon_config = {
    addon_name               = "kube-proxy"
    service_account          = "kube-proxy"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    preserve                 = true
    tags                     = {}
  }

  addon_config = merge(
    local.default_addon_config,
    var.addon_config
  )
}
