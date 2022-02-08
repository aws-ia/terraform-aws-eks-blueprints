module "launch_template_self_managed_ng" {
  source = "../launch-templates"

  eks_cluster_id = var.eks_cluster_id
  launch_template_config = {
    "${local.lt_self_managed_group_map_key}" = {
      ami                    = local.custom_ami_id
      launch_template_os     = local.self_managed_node_group["launch_template_os"]
      launch_template_prefix = local.self_managed_node_group["node_group_name"]
      instance_type          = local.self_managed_node_group["instance_type"]
      capacity_type          = local.self_managed_node_group["capacity_type"]
      iam_instance_profile   = aws_iam_instance_profile.self_managed_ng.name

      block_device_mappings = local.self_managed_node_group["block_device_mappings"]

      network_interfaces = [
        {
          public_ip = local.self_managed_node_group["public_ip"]
          security_groups = (
            local.self_managed_node_group["create_worker_security_group"] == true ? compact(
              flatten([[aws_security_group.self_managed_ng[0].id],
              local.self_managed_node_group["worker_additional_security_group_ids"]])) : compact(
              flatten([[var.worker_security_group_id],
          var.worker_additional_security_group_ids])))
        }
      ]
    }
  }

  tags = local.common_tags
}
