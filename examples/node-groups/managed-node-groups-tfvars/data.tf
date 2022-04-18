#------------------------------------------------------------------------
# Data Resources
#------------------------------------------------------------------------
data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks-blueprints.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-blueprints.eks_cluster_id
}
