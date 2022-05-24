resource "aws_eks_node_group" "managed_ng" {

  cluster_name           = var.context.eks_cluster_id
  node_group_name        = local.managed_node_group["enable_node_group_prefix"] == false ? local.managed_node_group["node_group_name"] : null
  node_group_name_prefix = local.managed_node_group["enable_node_group_prefix"] == true ? format("%s-", local.managed_node_group["node_group_name"]) : null

  node_role_arn   = local.managed_node_group["create_iam_role"] == true ? aws_iam_role.managed_ng[0].arn : local.managed_node_group["iam_role_arn"]
  subnet_ids      = length(local.managed_node_group["subnet_ids"]) == 0 ? (local.managed_node_group["subnet_type"] == "public" ? var.context.public_subnet_ids : var.context.private_subnet_ids) : local.managed_node_group["subnet_ids"]
  release_version = try(local.managed_node_group["release_version"], "") == "" || local.managed_node_group["custom_ami_id"] != "" ? null : local.managed_node_group["release_version"]

  ami_type             = local.managed_node_group["custom_ami_id"] != "" ? null : local.managed_node_group["ami_type"]
  capacity_type        = local.managed_node_group["capacity_type"]
  disk_size            = local.managed_node_group["create_launch_template"] == true ? null : local.managed_node_group["disk_size"]
  instance_types       = local.managed_node_group["instance_types"]
  force_update_version = local.managed_node_group["force_update_version"]
  version              = local.managed_node_group["custom_ami_id"] != "" ? null : var.context.cluster_version

  scaling_config {
    desired_size = local.managed_node_group["desired_size"]
    max_size     = local.managed_node_group["max_size"]
    min_size     = local.managed_node_group["min_size"]
  }

  dynamic "update_config" {
    for_each = local.managed_node_group["update_config"]
    content {
      max_unavailable            = try(update_config.value["max_unavailable"], null)
      max_unavailable_percentage = try(update_config.value["max_unavailable_percentage"], null)
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }

  dynamic "launch_template" {
    for_each = local.managed_node_group["create_launch_template"] == true ? [{
      id      = aws_launch_template.managed_node_groups[0].id
      version = aws_launch_template.managed_node_groups[0].default_version
    }] : []
    content {
      id      = launch_template.value["id"]
      version = launch_template.value["version"]
    }
  }

  dynamic "remote_access" {
    for_each = local.managed_node_group["remote_access"] == true ? [1] : []
    content {
      ec2_ssh_key               = local.managed_node_group["ec2_ssh_key"]
      source_security_group_ids = local.managed_node_group["ssh_security_group_id"]
    }
  }

  dynamic "taint" {
    for_each = local.managed_node_group["k8s_taints"]
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  labels = local.managed_node_group["k8s_labels"]

  tags = local.common_tags

  dynamic "timeouts" {
    for_each = local.managed_node_group["timeouts"]
    content {
      create = timeouts.value["create"]
      update = timeouts.value["update"]
      delete = timeouts.value["delete"]
    }
  }

  depends_on = [
    aws_iam_role.managed_ng,
    aws_iam_instance_profile.managed_ng,
    aws_iam_role_policy_attachment.managed_ng
  ]

}
