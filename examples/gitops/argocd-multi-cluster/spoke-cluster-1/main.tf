
#---------------------------------------------------------------
# Spoke Cluster
#---------------------------------------------------------------
module "spoke_cluster" {
  source = "../spoke-cluster"

  hub_cluster_name = "hub-cluster"
  spoke_cluster_name = "spoke-cluster-1"

}

