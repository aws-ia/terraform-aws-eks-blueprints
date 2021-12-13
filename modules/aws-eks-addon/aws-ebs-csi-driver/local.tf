
locals {
  default_add_on_config = {
    addon_name               = "aws-ebs-csi-driver"
    addon_version            = "v1.4.0-eksbuild.preview"
    service_account          = "ebs-csi-controller-sa"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }
  add_on_config = merge(
    local.default_add_on_config,
    var.add_on_config
  )
}
