#-------------------------------------------------
# EFS CSI Driver Helm Add-on
#-------------------------------------------------
module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "aws_efs_csi_driver" {
  name        = "${var.addon_context.eks_cluster_id}-efs-csi-policy"
  description = "IAM Policy for AWS EFS CSI Driver"
  policy      = data.aws_iam_policy_document.aws_efs_csi_driver.json
  tags        = var.addon_context.tags
}
