

# ---------------------------------------------------------------------------------------------------------------------
# MANAGED NODE GROUPS
# ---------------------------------------------------------------------------------------------------------------------
module "managed-node-groups" {
  for_each = length(var.managed_node_groups) > 0 && var.enable_managed_nodegroups ? var.managed_node_groups : {}

  source     = "./modules/aws-eks-managed-node-groups"
  managed_ng = each.value

  eks_cluster_name  = module.eks.cluster_id
  cluster_ca_base64 = module.eks.cluster_certificate_authority_data
  cluster_endpoint  = module.eks.cluster_endpoint

  private_subnet_ids = var.create_vpc == false ? var.private_subnet_ids : module.vpc.private_subnets
  public_subnet_ids  = var.create_vpc == false ? var.public_subnet_ids : module.vpc.public_subnets

  default_worker_security_group_id = module.eks.worker_security_group_id
  tags                             = module.eks-label.tags

  depends_on = [module.eks]
  # Ensure the cluster is fully created before trying to add the node group
  //  module_depends_on = [module.eks.kubernetes_config_map_id]

}
