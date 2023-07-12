# Get the availability zones for the current region
data "aws_availability_zones" "available" {}

data "aws_network_interfaces" "eks_managed_eni" {
  filter {
    name   = "description"
    values = [format("%s %s", "Amazon EKS", var.eks_cluster_name)]
  }
  depends_on = [module.eks]
}

data "aws_network_interface" "eks_managed_eni" {
  # Assumption based on the fact that EKS creates at least two ENIs in the 
  # customer managed subnets
  count = 2
  id    = data.aws_network_interfaces.eks_managed_eni.ids[count.index]
}

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