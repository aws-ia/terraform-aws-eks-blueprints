resource "aws_autoscaling_group" "self_managed_ng" {
  name = "${var.context.eks_cluster_id}-${local.self_managed_node_group["node_group_name"]}"

  max_size            = local.self_managed_node_group["max_size"]
  min_size            = local.self_managed_node_group["min_size"]
  vpc_zone_identifier = length(local.self_managed_node_group["subnet_ids"]) == 0 ? (local.self_managed_node_group["subnet_type"] == "public" ? var.context.public_subnet_ids : var.context.private_subnet_ids) : local.self_managed_node_group["subnet_ids"]

  capacity_rebalance = local.self_managed_node_group["capacity_rebalance"]
  target_group_arns  = try(local.self_managed_node_group["target_group_arns"], null)

  dynamic "launch_template" {
    for_each = !local.needs_mixed_instances_policy ? [1] : []

    content {
      id      = module.launch_template_self_managed_ng.launch_template_id[local.lt_self_managed_group_map_key]
      version = module.launch_template_self_managed_ng.launch_template_latest_version[local.lt_self_managed_group_map_key]
    }
  }

  dynamic "mixed_instances_policy" {
    for_each = local.needs_mixed_instances_policy ? [1] : []

    content {
      instances_distribution {
        on_demand_base_capacity                  = 0
        on_demand_percentage_above_base_capacity = local.self_managed_node_group["capacity_type"] == "spot" ? 0 : 100
        spot_allocation_strategy                 = local.self_managed_node_group["spot_allocation_strategy"]
      }

      launch_template {
        launch_template_specification {
          launch_template_id = module.launch_template_self_managed_ng.launch_template_id[local.lt_self_managed_group_map_key]
          version            = module.launch_template_self_managed_ng.launch_template_latest_version[local.lt_self_managed_group_map_key]
        }

        dynamic "override" {
          for_each = [
            for x in local.self_managed_node_group["instance_types"] : x
            if length(local.self_managed_node_group["instance_types"]) > 1
          ]

          content {
            instance_type = override.value
          }
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = local.common_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  depends_on = [
    aws_iam_role.self_managed_ng,
    aws_iam_instance_profile.self_managed_ng,
    aws_iam_role_policy_attachment.self_managed_ng
  ]
}
