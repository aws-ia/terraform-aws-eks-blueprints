module "aws-eks-self-managed-node-groups" {
  for_each = var.self_managed_node_groups

  source                          = "./modules/aws-eks-self-managed-node-groups"
  self_managed_ng                 = each.value
  vpc_id                          = var.create_vpc == false ? var.vpc_id : module.vpc.vpc_id
  self_managed_private_subnet_ids = var.create_vpc == false ? var.self_managed_private_subnet_ids : module.vpc.private_subnets
  self_managed_public_subnet_ids  = var.create_vpc == false ? var.self_managed_public_subnet_ids : module.vpc.public_subnets
  cluster_full_name               = module.eks.cluster_id
  cluster_endpoint                = module.eks.cluster_endpoint
  cluster_ca                      = module.eks.cluster_certificate_authority_data
  cluster_security_group          = module.eks.cluster_primary_security_group_id
  cluster_autoscaler_enable       = var.cluster_autoscaler_enable
  cluster_version                 = var.kubernetes_version
  common_tags                     = module.eks-label.tags

  depends_on = [module.eks]

}