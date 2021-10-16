
locals {
  default_fargate_profiles = {
    fargate_profile_name       = ""
    fargate_profile_namespaces = []
    create_iam_role            = true
    k8s_labels                 = {}
    k8s_taints                 = []
    additional_tags            = {}
    subnet_ids                 = []
  }
  fargate_profiles = merge(
    local.default_fargate_profiles,
    var.fargate_profile
  )

  fargate_tags = merge(
    { "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" },
  { "k8s.io/cluster/${var.eks_cluster_name}" = "owned" })

}
