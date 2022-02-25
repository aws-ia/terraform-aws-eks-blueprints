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

      pre_userdata         = local.self_managed_node_group["pre_userdata"]
      bootstrap_extra_args = local.self_managed_node_group["bootstrap_extra_args"]
      post_userdata        = local.self_managed_node_group["post_userdata"]
      kubelet_extra_args   = local.self_managed_node_group["kubelet_extra_args"]
      monitoring           = local.self_managed_node_group["enable_monitoring"]

      iam_instance_profile = aws_iam_instance_profile.self_managed_ng.name

      block_device_mappings = [for device in local.self_managed_node_group["block_device_mappings"] : {
        device_name           = device.device_name
        volume_type           = try(device.volume_type, null)
        volume_size           = try(device.volume_size, null)
        delete_on_termination = try(device.delete_on_termination, true)
        encrypted             = try(device.encrypted, true)
        kms_key_id = var.worker_create_kms_key && try(
          length(trimspace(var.worker_kms_key_arn)), 0) == 0 ? module.kms[0].key_arn : try(
        length(trimspace(var.worker_kms_key_arn)), 0) > 0 ? var.worker_kms_key_arn : null
        iops       = try(device.iops, null)
        throughput = try(device.throughput, null)
        }
      ]

      network_interfaces = [
        {
          public_ip = local.self_managed_node_group["public_ip"]
          security_groups = (
            local.self_managed_node_group["create_worker_security_group"] == true
            ? compact(flatten([[aws_security_group.self_managed_ng[0].id], var.worker_additional_security_group_ids]))
          : compact(flatten([[var.worker_security_group_id], var.worker_additional_security_group_ids])))
        }
      ]
    }
  }

  tags = local.common_tags
}
