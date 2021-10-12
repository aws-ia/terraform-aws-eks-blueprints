resource "aws_launch_template" "self_managed_ng" {
  name        = "${var.eks_cluster_name}-${local.self_managed_node_group["node_group_name"]}"
  description = "Launch Template for EKS Self Managed Node Groups"

  instance_type = local.self_managed_node_group["instance_type"]
  image_id      = local.custom_ami_id

  update_default_version = true
  user_data              = local.custom_userdata_base64

  dynamic "instance_market_options" {
    for_each = local.self_managed_node_group["capacity_type"] == "spot" ? [1] : []
    content {
      market_type = local.self_managed_node_group["capacity_type"]
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.self_managed_ng.name
  }

  ebs_optimized = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = "gp2"
      volume_size = local.self_managed_node_group["disk_size"]
      encrypted   = true
      # kms_key_id            = ""
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = var.http_endpoint
    http_tokens                 = var.http_tokens
    http_put_response_hop_limit = var.http_put_response_hop_limit
  }

  monitoring {
    enabled = true
  }

  lifecycle {
    create_before_destroy = true
  }

  network_interfaces {
    associate_public_ip_address = local.self_managed_node_group["public_ip"]
    security_groups             = local.self_managed_node_group["create_worker_security_group"] == true ? [aws_security_group.self_managed_ng[0].id] : [var.worker_security_group_id]
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.common_tags
  }

  depends_on = [
    aws_iam_role.self_managed_ng,
    aws_iam_instance_profile.self_managed_ng,
    aws_iam_role_policy_attachment.self_managed_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.self_managed_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.self_managed_AmazonEC2ContainerRegistryReadOnly,
  ]

}
