
module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "this" {
  name        = "${var.addon_context.eks_cluster_id}-${local.service_account_name}-policy"
  path        = "/"
  description = "A generic AWS IAM policy for the ingress nginx irsa."
  policy      = data.aws_iam_policy_document.this.json

  tags = merge(
    {
      "Name"                         = "${var.addon_context.eks_cluster_id}-${local.service_account_name}-irsa-policy",
      "app.kubernetes.io/managed-by" = "terraform-ssp-amazon-eks"
    },
    var.tags
  )
}
