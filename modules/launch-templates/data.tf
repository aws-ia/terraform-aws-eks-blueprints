data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_id
}
