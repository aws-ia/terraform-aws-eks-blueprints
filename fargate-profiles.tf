

# ---------------------------------------------------------------------------------------------------------------------
# FARGATE PROFILES
# ---------------------------------------------------------------------------------------------------------------------
module "fargate-profiles" {
  for_each = length(var.fargate_profiles) > 0 && var.enable_fargate ? var.fargate_profiles : {}

  source          = "./modules/aws-eks-fargate"
  fargate_profile = each.value

  eks_cluster_name   = module.eks.cluster_id
  private_subnet_ids = var.create_vpc == false ? var.private_subnet_ids : module.vpc.private_subnets
  public_subnet_ids  = var.create_vpc == false ? var.public_subnet_ids : module.vpc.public_subnets

  tags = module.eks-label.tags

  depends_on = [module.eks]

}

