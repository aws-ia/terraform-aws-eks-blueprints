module "aws-eks-self-managed-node-groups" {
  for_each = length(var.self_managed_node_groups) > 0 && var.enable_self_managed_nodegroups ? var.self_managed_node_groups : {}

  source          = "./modules/aws-eks-self-managed-node-groups"
  self_managed_ng = each.value

  eks_cluster_name  = module.eks.cluster_id
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_ca_base64 = module.eks.cluster_certificate_authority_data
  cluster_version   = var.kubernetes_version
  tags              = module.eks-label.tags


  vpc_id             = var.create_vpc == false ? var.vpc_id : module.vpc.vpc_id
  private_subnet_ids = var.create_vpc == false ? var.private_subnet_ids : module.vpc.private_subnets
  public_subnet_ids  = var.create_vpc == false ? var.public_subnet_ids : module.vpc.public_subnets

  default_worker_security_group_id  = module.eks.worker_security_group_id
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id

  depends_on = [module.eks]
  # Ensure the cluster is fully created before trying to add the node group
  //  module_depends_on = [module.eks.kubernetes_config_map_id]

}