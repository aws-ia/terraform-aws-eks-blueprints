data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_id
}

data "aws_eks_addon_version" "latest" {
  for_each = toset(["vpc-cni", "coredns", "kube-proxy", "aws-ebs-csi-driver"])

  addon_name         = each.value
  kubernetes_version = local.cluster_version
  most_recent        = true
}
