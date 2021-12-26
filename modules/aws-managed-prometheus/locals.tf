locals {
  amazon_prometheus_workspace_alias           = var.amazon_prometheus_workspace_alias == null ? format("%s-%s", "amp-ws-", var.eks_cluster_id) : var.amazon_prometheus_workspace_alias

  irsa_config = {
    ingest = {
      service_account  = format("%s-%s", var.eks_cluster_id, "amp-ingest"),
      create_kubernetes_namespace = true,
      irsa_iam_policies = [aws_iam_policy.ingest.arn]

    },
    query = {
      service_account  = format("%s-%s", var.eks_cluster_id, "amp-query"),
      create_kubernetes_namespace = false,
      irsa_iam_policies = [aws_iam_policy.query.arn]
    }
  }
}
