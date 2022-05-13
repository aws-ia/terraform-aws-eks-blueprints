resource "aws_launch_template" "managed_node_groups" {
  count = local.managed_node_group["create_launch_template"] == true ? 1 : 0

  name                   = "${var.context.eks_cluster_id}-${local.managed_node_group["node_group_name"]}"
  description            = "Launch Template for EKS Managed Node Groups"
  update_default_version = true

  user_data = local.userdata_base64

  dynamic "block_device_mappings" {
    for_each = local.managed_node_group["block_device_mappings"]

    content {
      device_name = try(block_device_mappings.value.device_name, null)

      ebs {
        delete_on_termination = try(block_device_mappings.value.delete_on_termination, true)
        encrypted             = try(block_device_mappings.value.encrypted, true)
        kms_key_id            = try(block_device_mappings.value.kms_key_id, null)
        volume_size           = try(block_device_mappings.value.volume_size, null)
        volume_type           = try(block_device_mappings.value.volume_type, null)
        iops                  = try(block_device_mappings.value.iops, null)
        throughput            = try(block_device_mappings.value.throughput, null)
      }
    }
  }

  ebs_optimized = true

  image_id = local.managed_node_group["custom_ami_id"]

  monitoring {
    enabled = local.managed_node_group["enable_monitoring"]
  }

  metadata_options {
    http_endpoint               = try(var.context.http_endpoint, "enabled")
    http_tokens                 = try(var.context.http_tokens, "required") #tfsec:ignore:aws-autoscaling-enforce-http-token-imds
    http_put_response_hop_limit = try(var.context.http_put_response_hop_limit, 2)
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags
  }

  network_interfaces {
    associate_public_ip_address = local.managed_node_group["public_ip"]
    security_groups             = var.context.worker_security_group_ids
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
    aws_iam_role_policy_attachment.managed_ng
  ]
}
