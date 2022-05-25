#-------------------------------------
# Helm Add-on
#-------------------------------------

module "helm_addon" {
  source            = "../helm-addon"
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  set_values        = local.set_values
  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
}

#------------------------------------
# IAM Policy
#------------------------------------

resource "aws_iam_policy" "external_dns" {
  description = "External DNS IAM policy."
  name        = "${var.addon_context.eks_cluster_id}-${local.helm_config["name"]}-irsa"
  path        = var.addon_context.irsa_iam_role_path
  policy      = data.aws_iam_policy_document.external_dns_iam_policy_document.json
}
