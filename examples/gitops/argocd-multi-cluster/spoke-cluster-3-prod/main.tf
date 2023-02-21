
#---------------------------------------------------------------
# Spoke Cluster
#---------------------------------------------------------------
module "spoke_cluster" {
  source = "../spoke-cluster-template"

  hub_cluster_name   = "hub-cluster"
  spoke_cluster_name = "cluster-prod"
  environment        = "prod"
  addons = {
    enable_aws_load_balancer_controller = true
    enable_metrics_server               = true
    enable_cert_manager                 = true
    enable_gatekeeper                   = true
  }

}

