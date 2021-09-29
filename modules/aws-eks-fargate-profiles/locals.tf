
locals {
  default_fargate_profiles = {
    fargate_profile_name          = ""
    fargate_profile_namespaces    = []
    create_iam_role               = "false"
    k8s_labels                    = {}
    k8s_taints                    = []
    additional_tags               = {}
    additional_security_group_ids = []
    source_security_group_ids     = ""
  }
  fargate_profiles = merge(
    local.default_fargate_profiles,
    var.fargate_profile,
    { subnet_ids = var.fargate_profile["subnet_ids"] == [] ? var.private_subnet_ids : var.fargate_profile["subnet_ids"] }
  )

  fargate_tags = merge(
    { "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" },
  { "k8s.io/cluster/${var.eks_cluster_name}" = "owned" })

}
