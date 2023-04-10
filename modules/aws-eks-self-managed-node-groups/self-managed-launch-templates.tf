module "launch_template_self_managed_ng" {
  source = "../launch-templates"

  eks_cluster_id = var.context.eks_cluster_id
  launch_template_config = {
    (local.lt_self_managed_group_map_key) = {
      ami                    = local.custom_ami_id
      launch_template_os     = local.self_managed_node_group["launch_template_os"]
      launch_template_prefix = local.self_managed_node_group["node_group_name"]
      instance_type          = local.self_managed_node_group["instance_type"]
      capacity_type          = local.self_managed_node_group["capacity_type"] == "spot" ? "spot" : local.self_managed_node_group["capacity_type"]
      iam_instance_profile   = local.self_managed_node_group["iam_instance_profile_name"] == null ? aws_iam_instance_profile.self_managed_ng[0].name : local.self_managed_node_group["iam_instance_profile_name"]

      pre_userdata         = local.self_managed_node_group["pre_userdata"]
      bootstrap_extra_args = local.self_managed_node_group["bootstrap_extra_args"]
      post_userdata        = local.self_managed_node_group["post_userdata"]
      kubelet_extra_args   = local.self_managed_node_group["kubelet_extra_args"]
      monitoring           = local.self_managed_node_group["enable_monitoring"]

      enable_metadata_options     = try(var.self_managed_ng.enable_metadata_options, true)
      http_endpoint               = try(var.self_managed_ng.http_endpoint, "enabled")
      http_tokens                 = try(var.self_managed_ng.http_tokens, "required")
      http_put_response_hop_limit = try(var.self_managed_ng.http_put_response_hop_limit, 2)
      http_protocol_ipv6          = try(var.self_managed_ng.http_protocol_ipv6, null)
      instance_metadata_tags      = try(var.self_managed_ng.instance_metadata_tags, null)
      placement                   = try(var.self_managed_ng.placement, null)

      service_ipv6_cidr = var.context.service_ipv6_cidr
      service_ipv4_cidr = var.context.service_ipv4_cidr

      block_device_mappings  = local.self_managed_node_group["block_device_mappings"]
      format_mount_nvme_disk = local.self_managed_node_group["format_mount_nvme_disk"]

      network_interfaces = [
        {
          public_ip       = local.self_managed_node_group["public_ip"]
          security_groups = var.context.worker_security_group_ids
        }
      ]
    }
  }

  tags = local.common_tags
}
