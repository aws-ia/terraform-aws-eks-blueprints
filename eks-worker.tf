# ---------------------------------------------------------------------------------------------------------------------
# MANAGED NODE GROUPS
# ---------------------------------------------------------------------------------------------------------------------

module "aws_eks_managed_node_groups" {
  source = "./modules/aws-eks-managed-node-groups"

  for_each = { for key, value in var.managed_node_groups : key => value
    if length(var.managed_node_groups) > 0
  }

  managed_ng = each.value
  context    = local.node_group_context

  depends_on = [kubernetes_config_map.aws_auth]
}

# ---------------------------------------------------------------------------------------------------------------------
# SELF MANAGED NODE GROUPS
# ---------------------------------------------------------------------------------------------------------------------

module "aws_eks_self_managed_node_groups" {
  source = "./modules/aws-eks-self-managed-node-groups"

  for_each = { for key, value in var.self_managed_node_groups : key => value
    if length(var.self_managed_node_groups) > 0
  }

  self_managed_ng = each.value
  context         = local.node_group_context

  depends_on = [kubernetes_config_map.aws_auth]
}

# ---------------------------------------------------------------------------------------------------------------------
# FARGATE PROFILES
# ---------------------------------------------------------------------------------------------------------------------

module "aws_eks_fargate_profiles" {
  source = "./modules/aws-eks-fargate-profiles"

  for_each = { for k, v in var.fargate_profiles : k => v if length(var.fargate_profiles) > 0 }

  fargate_profile = each.value
  context         = local.fargate_context

  depends_on = [kubernetes_config_map.aws_auth]
}
