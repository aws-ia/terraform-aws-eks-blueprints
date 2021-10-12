
resource "aws_launch_template" "managed_node_groups" {
  name                   = "${var.eks_cluster_name}-${local.managed_node_group["node_group_name"]}"
  description            = "Launch Template for EKS Managed Node Groups"
  update_default_version = true

  user_data = local.userdata_base64

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = local.managed_node_group["disk_size"]
      volume_type           = local.managed_node_group["disk_type"]
      delete_on_termination = true
      encrypted             = true
      # kms_key_id            = ""
    }
  }

  ebs_optimized = true

  image_id = local.managed_node_group["custom_ami_id"] == "" ? "" : local.managed_node_group["custom_ami_id"]
  # key_name = local.remote_access_enabled ? var.ec2_ssh_key : null

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = var.http_endpoint
    http_tokens                 = var.http_tokens
    http_put_response_hop_limit = var.http_put_response_hop_limit
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags
  }

  network_interfaces {
    associate_public_ip_address = local.managed_node_group["public_ip"]
    security_groups             = local.managed_node_group["create_worker_security_group"] == true ? [aws_security_group.managed_ng[0].id] : [var.worker_security_group_id]
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_role.managed_ng,
    aws_iam_instance_profile.managed_ng,
    aws_iam_role_policy_attachment.managed_ng_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.managed_ng_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.managed_ng_AmazonEC2ContainerRegistryReadOnly,
  ]

}
