
locals {
  default_aws_ebs_csi_driver_config = {
    addon_name               = "aws-ebs-csi-driver"
    addon_version            = "v1.4.0-eksbuild.preview"
    service_account          = "ebs-csi-controller-sa"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }
  aws_ebs_csi_driver_config = merge(
    local.default_aws_ebs_csi_driver_config,
    var.eks_addon_aws_ebs_csi_driver_config
  )
}
