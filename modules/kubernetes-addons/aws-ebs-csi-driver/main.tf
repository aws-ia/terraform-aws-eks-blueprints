
resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = local.add_on_config["addon_name"]
  addon_version            = local.add_on_config["addon_version"]
  resolve_conflicts        = local.add_on_config["resolve_conflicts"]
  service_account_role_arn = local.add_on_config["service_account_role_arn"] == "" ? module.irsa_addon.irsa_iam_role_arn : local.add_on_config["service_account_role_arn"]
  tags = merge(
    var.addon_context.tags,
    local.add_on_config["tags"],
    { "eks_addon" = "aws-ebs-csi-driver" }
  )
  depends_on = [module.irsa_addon]
}

module "irsa_addon" {
  source                            = "../../../modules/irsa"
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.add_on_config["namespace"]
  kubernetes_service_account        = local.add_on_config["service_account"]
  irsa_iam_policies                 = concat([aws_iam_policy.aws_ebs_csi_driver.arn], local.add_on_config["additional_iam_policies"])
  addon_context                     = var.addon_context
}

resource "aws_iam_policy" "aws_ebs_csi_driver" {
  description = "IAM Policy for AWS EBS CSI Driver"
  name        = "${var.addon_context.eks_cluster_id}-${local.add_on_config["addon_name"]}-irsa"
  path        = var.iam_role_path
  policy      = data.aws_iam_policy_document.aws-ebs-csi-driver.json
}
