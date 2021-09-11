resource "aws_autoscaling_group" "self_managed_ng" {
  name                = format("%s%s", "${var.cluster_full_name}-${local.self_managed_nodegroup_name}", "-")
  max_size            = local.self_managed_node_max_size
  min_size            = local.self_managed_node_min_size
  vpc_zone_identifier = local.subnet_ids

  launch_template {
    id      = aws_launch_template.self_managed_ng.id
    version = "$Latest"
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
}
