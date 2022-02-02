resource "aws_launch_template" "this" {
  for_each = local.launch_template_config

  name        = format("%s-%s", each.value.launch_template_prefix, var.eks_cluster_id)
  description = "Launch Template for Karpenter Nodes"

  image_id               = each.value.ami
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/templates/userdata-${each.value.launch_template_os}.tpl",
    {
      pre_userdata         = each.value.pre_userdata
      post_userdata        = each.value.post_userdata
      bootstrap_extra_args = each.value.bootstrap_extra_args
      kubelet_extra_args   = each.value.kubelet_extra_args
      eks_cluster_id       = var.eks_cluster_id
      cluster_ca_base64    = data.aws_eks_cluster.eks.certificate_authority[0].data
      cluster_endpoint     = data.aws_eks_cluster.eks.endpoint
  }))

  iam_instance_profile {
    name = each.value.iam_instance_profile
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
        volume_size           = try(block_device_mappings.value.volume_size, null)
        volume_type           = try(block_device_mappings.value.volume_type, null)
        iops                  = block_device_mappings.value.volume_type == "gp3" || block_device_mappings.value.volume_type == "io1" || block_device_mappings.value.volume_type == "io2" ? block_device_mappings.value.iops : null
        throughput            = block_device_mappings.value.volume_type == "gp3" ? block_device_mappings.value.throughput : null
      }
    }
  }

  vpc_security_group_ids = each.value.vpc_security_group_ids != "" ? [each.value.vpc_security_group_ids] : null

  dynamic "network_interfaces" {
    for_each = each.value.network_interfaces
    content {
      associate_public_ip_address = try(network_interfaces.value.public_ip, false)
      security_groups             = each.value.network_interfaces.security_groups != "" ? [network_interfaces.value.security_groups] : null
    }
  }

  metadata_options {
    http_endpoint               = each.value.http_endpoint
    http_tokens                 = each.value.http_tokens
    http_put_response_hop_limit = each.value.http_put_response_hop_limit
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = length(var.tags) > 0 ? var.tags : { Name = "eks" }
  }
}
