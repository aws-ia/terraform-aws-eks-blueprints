managed_node_groups = {
  eks-ng01 = {
    node_group_name = "eks-ng01"

    desired_size    = 2
    min_size        = 2
    max_size        = 3
    max_unavailable = 1

    ami_type       = "BOTTLEROCKET_x86_64"
    capacity_type  = "ON_DEMAND"
    instance_types = ["t2.medium"]
    disk_size      = 20
  }
}

vpc_cidr = "10.0.0.0/16"
