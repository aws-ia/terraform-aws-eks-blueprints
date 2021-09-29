resource "aws_autoscaling_group" "self_managed_ng" {
  name = "${var.eks_cluster_name}-${local.self_managed_node_group["node_group_name"]}"

  max_size            = local.self_managed_node_group["max_size"]
  min_size            = local.self_managed_node_group["min_size"]
  vpc_zone_identifier = local.self_managed_node_group["subnet_ids"]

  launch_template {
    id      = aws_launch_template.self_managed_ng.id
    version = aws_launch_template.self_managed_ng.latest_version
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
    aws_iam_role_policy_attachment.self_managed_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.self_managed_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.self_managed_AmazonEC2ContainerRegistryReadOnly,
  ]

}
