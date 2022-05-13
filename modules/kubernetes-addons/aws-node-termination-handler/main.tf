module "queue_processor" {
  count = var.queue_processor ? 1 : 0

  source                  = "./queue-processor"
  helm_config             = var.helm_config
  autoscaling_group_names = var.autoscaling_group_names
  irsa_policies           = var.irsa_policies
  addon_context           = var.addon_context
}

module "imds_processor" {
  count = !var.queue_processor ? 1 : 0

  source        = "./imds-processor"
  helm_config   = var.helm_config
  addon_context = var.addon_context
}
