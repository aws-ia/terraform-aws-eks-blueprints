

# ---------------------------------------------------------------------------------------------------------------------
# MANAGED NODE GROUPS
# ---------------------------------------------------------------------------------------------------------------------
module "managed-node-groups" {
  for_each = var.managed_node_groups

  source     = "./modules/aws-eks-managed-node-groups"
  managed_ng = each.value

  eks_cluster_name          = module.eks.cluster_id
  private_subnet_ids        = var.create_vpc == false ? var.private_subnet_ids : module.vpc.private_subnets
  public_subnet_ids         = var.create_vpc == false ? var.public_subnet_ids : module.vpc.public_subnets
  cluster_ca_base64         = module.eks.cluster_certificate_authority_data
  cluster_endpoint          = module.eks.cluster_endpoint
  cluster_autoscaler_enable = var.cluster_autoscaler_enable
  worker_security_group_id  = module.eks.worker_security_group_id # TODO Create New SecGroup for each node group
  tags                      = module.eks-label.tags

  depends_on = [module.eks]

}
