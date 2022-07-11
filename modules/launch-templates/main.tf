resource "aws_launch_template" "this" {
  for_each = local.launch_template_config

  name        = format("%s-%s", each.value.launch_template_prefix, var.eks_cluster_id)
  description = "Launch Template for Amazon EKS Worker Nodes"

  image_id               = each.value.ami
  update_default_version = true

  instance_type = try(length(each.value.instance_type), 0) == 0 ? null : each.value.instance_type

  user_data = base64encode(templatefile("${path.module}/templates/userdata-${each.value.launch_template_os}.tpl",
    {
      pre_userdata           = each.value.pre_userdata
      post_userdata          = each.value.post_userdata
      bootstrap_extra_args   = each.value.bootstrap_extra_args
      kubelet_extra_args     = each.value.kubelet_extra_args
      eks_cluster_id         = var.eks_cluster_id
      cluster_ca_base64      = data.aws_eks_cluster.eks.certificate_authority[0].data
      cluster_endpoint       = data.aws_eks_cluster.eks.endpoint
      service_ipv6_cidr      = try(each.value.service_ipv6_cidr, "")
      service_ipv4_cidr      = try(each.value.service_ipv4_cidr, "")
      format_mount_nvme_disk = each.value.format_mount_nvme_disk
  }))

  dynamic "iam_instance_profile" {
    for_each = try(length(each.value.iam_instance_profile), 0) == 0 ? {} : { iam_instance_profile : each.value.iam_instance_profile }
    iterator = iam
    content {
      name = iam.value
    }
  }

  dynamic "instance_market_options" {
    for_each = trimspace(lower(each.value.capacity_type)) == "spot" ? { enabled = true } : {}

    content {
      market_type = each.value.capacity_type
    }
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

  vpc_security_group_ids = try(length(each.value.vpc_security_group_ids), 0) == 0 ? null : each.value.vpc_security_group_ids

  dynamic "network_interfaces" {
    for_each = each.value.network_interfaces
    content {
      associate_public_ip_address = try(network_interfaces.value.public_ip, false)
      security_groups             = try(length(network_interfaces.value.security_groups), 0) == 0 ? null : network_interfaces.value.security_groups
    }
  }

  dynamic "monitoring" {
    for_each = each.value.monitoring ? [1] : []

    content {
      enabled = true
    }
  }

  dynamic "metadata_options" {
    for_each = each.value.enable_metadata_options ? [1] : []

    content {
      http_endpoint               = try(each.value.http_endpoint, "enabled")
      http_tokens                 = try(each.value.http_tokens, "required")
      http_put_response_hop_limit = try(each.value.http_put_response_hop_limit, 2)
      http_protocol_ipv6          = try(each.value.http_protocol_ipv6, "disabled")
      instance_metadata_tags      = try(each.value.instance_metadata_tags, "disabled")
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = length(var.tags) > 0 ? var.tags : { Name = "eks" }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = length(var.tags) > 0 ? var.tags : { Name = "eks-volume" }
  }
}
