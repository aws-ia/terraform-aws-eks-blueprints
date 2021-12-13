
locals {
  default_eks_addon_vpc_cni_config = {
    addon_name               = "vpc-cni"
    addon_version            = "v1.10.1-eksbuild.1"
    service_account          = "aws-node"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }
  eks_addon_vpc_cni_config = merge(
    local.default_eks_addon_vpc_cni_config,
    var.eks_addon_vpc_cni_config
  )
}
