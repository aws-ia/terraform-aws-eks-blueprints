data "aws_security_group" "eks_worker_group" {
  id = var.eks_worker_security_group_id
}
