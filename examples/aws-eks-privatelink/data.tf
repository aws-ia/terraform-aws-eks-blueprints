# Get the availability zones for the current region
data "aws_availability_zones" "available" {}

data "aws_security_group" "eks_managed_sg" {
  filter {
    name   = "tag:aws:eks:cluster-name"
    values = [var.eks_cluster_name]
  }
  depends_on = [module.eks]
}

data "dns_a_record_set" "nlb" {
  host       = module.nlb.lb_dns_name
  depends_on = [module.nlb]
}
