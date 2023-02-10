
#---------------------------------------------------------------
# Spoke Cluster
#---------------------------------------------------------------
module "spoke_cluster" {
  source = "../spoke-cluster-template"

  hub_cluster_name   = "hub-cluster"
  spoke_cluster_name = "cluster-2"

}

