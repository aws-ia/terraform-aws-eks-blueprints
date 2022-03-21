locals {
  default_fargate_profiles = {
    fargate_profile_name       = ""
    fargate_profile_namespaces = []
    create_iam_role            = true
    k8s_labels                 = {}
    additional_tags            = {}
    subnet_ids                 = []
  }
  fargate_profiles = merge(
    local.default_fargate_profiles,
    var.fargate_profile
  )

  fargate_tags = merge(
    { "kubernetes.io/cluster/${var.context.eks_cluster_id}" = "owned" },
  { "k8s.io/cluster/${var.context.eks_cluster_id}" = "owned" })

  policy_arn = "arn:${var.context.aws_partition_id}:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"

}
