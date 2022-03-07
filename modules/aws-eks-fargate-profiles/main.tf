resource "aws_eks_fargate_profile" "eks_fargate" {
  cluster_name           = var.context.eks_cluster_id
  fargate_profile_name   = "${local.fargate_profiles["fargate_profile_name"]}-${var.context.eks_cluster_id}"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = local.fargate_profiles["subnet_ids"]

  tags = merge(var.context.tags,
    local.fargate_profiles["additional_tags"],
    local.fargate_tags
  )

  dynamic "selector" {
    for_each = toset(local.fargate_profiles["fargate_profile_namespaces"])
    content {
      namespace = selector.value.namespace
      labels    = selector.value.k8s_labels
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.fargate_pod_execution_role_policy,
  ]
}
