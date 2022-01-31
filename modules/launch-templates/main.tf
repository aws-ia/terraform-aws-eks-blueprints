resource "aws_launch_template" "this" {
  for_each = local.launch_template_config

  name        = format("%s-%s", each.value.launch_template_id, var.eks_cluster_id)
  description = "Launch Template for Karpenter Nodes"

  image_id               = each.value.ami
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/templates/userdata-${each.value.launch_template_os}.tpl",
    {
      pre_userdata         = try(each.value.pre_userdata, null)
      post_userdata        = try(each.value.post_userdata, null)
      bootstrap_extra_args = try(each.value.bootstrap_extra_args, null)
      kubelet_extra_args   = try(each.value.kubelet_extra_args, null)
      eks_cluster_id       = var.eks_cluster_id
      cluster_ca_base64    = data.aws_eks_cluster.eks.certificate_authority[0].data
      cluster_endpoint     = data.aws_eks_cluster.eks.endpoint
  }))

  vpc_security_group_ids = [
    var.worker_security_group_id
  ]

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  ebs_optimized = true

  dynamic "block_device_mappings" {
    for_each = each.value.block_device_mappings

    content {
      device_name = try(block_device_mappings.value.device_name, null)

      ebs {
        delete_on_termination = try(block_device_mappings.value.delete_on_termination, true)
        encrypted             = try(block_device_mappings.value.encrypted, true)
        kms_key_id            = try(block_device_mappings.value.kms_key_id, null)
        volume_size           = try(block_device_mappings.value.disk_size, null)
        volume_type           = try(block_device_mappings.value.disk_type, null)
      }
    }
  }

  metadata_options {
    http_endpoint               = var.http_endpoint
    http_tokens                 = var.http_tokens
    http_put_response_hop_limit = var.http_put_response_hop_limit
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = length(var.tags) > 0 ? var.tags : { Name = "eks" }
  }
}
