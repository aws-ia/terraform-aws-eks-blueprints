
locals {
  default_addon_config = {
    addon_name               = "aws-ebs-csi-driver"
    service_account          = "ebs-csi-controller-sa"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }

  addon_config = merge(
    local.default_addon_config,
    var.addon_config
  )
}
