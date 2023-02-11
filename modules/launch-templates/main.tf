data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_id
}

#tfsec:ignore:aws-autoscaling-enforce-http-token-imds
resource "aws_launch_template" "this" {
  for_each = var.launch_template_config

  name        = format("%s-%s", try(each.value.launch_template_prefix, ""), var.eks_cluster_id)
  description = "Launch Template for Amazon EKS Worker Nodes"

  image_id               = try(each.value.ami, null)
  update_default_version = true

  instance_type = try(each.value.instance_type, null)

  user_data = base64encode(templatefile("${path.module}/templates/userdata-${try(each.value.launch_template_os, "amazonlinux2eks")}.tpl",
    {
      pre_userdata           = try(each.value.pre_userdata, "")
      post_userdata          = try(each.value.post_userdata, "")
      bootstrap_extra_args   = try(each.value.bootstrap_extra_args, "")
      kubelet_extra_args     = try(each.value.kubelet_extra_args, "")
      eks_cluster_id         = var.eks_cluster_id
      cluster_ca_base64      = data.aws_eks_cluster.eks.certificate_authority[0].data
      cluster_endpoint       = data.aws_eks_cluster.eks.endpoint
      service_ipv6_cidr      = try(each.value.service_ipv6_cidr, "") == null ? "" : try(each.value.service_ipv6_cidr, "")
      service_ipv4_cidr      = try(each.value.service_ipv4_cidr, "") == null ? "" : try(each.value.service_ipv4_cidr, "")
      format_mount_nvme_disk = try(each.value.format_mount_nvme_disk, false)
  }))

  dynamic "iam_instance_profile" {
    for_each = length(try(each.value.iam_instance_profile, {})) > 0 ? { iam_instance_profile : each.value.iam_instance_profile } : {}
    iterator = iam
    content {
      name = iam.value
    }
  }

  dynamic "instance_market_options" {
    for_each = trimspace(lower(try(each.value.capacity_type, ""))) == "spot" ? { enabled = true } : {}

    content {
      market_type = each.value.capacity_type
    }
  }

  ebs_optimized = true

  dynamic "block_device_mappings" {
    for_each = try(each.value.block_device_mappings, {})

    content {
      device_name = try(block_device_mappings.value.device_name, null)

      ebs {
        delete_on_termination = try(block_device_mappings.value.delete_on_termination, true)
        encrypted             = try(block_device_mappings.value.encrypted, true)
        kms_key_id            = try(block_device_mappings.value.kms_key_id, null)
        volume_size           = try(block_device_mappings.value.volume_size, null)
        volume_type           = try(block_device_mappings.value.volume_type, null)
        iops                  = contains(["gp3", "io1", "io2"], try(block_device_mappings.value.volume_type, "")) ? try(block_device_mappings.value.iops, 3000) : null
        throughput            = try(block_device_mappings.value.volume_type, "") == "gp3" ? try(block_device_mappings.value.throughput, 125) : null
      }
    }
  }

  dynamic "placement" {
    for_each = try(each.value.placement, null) != null ? [each.value.placement] : []
    content {
      affinity          = lookup(placement.value, "affinity", null)
      availability_zone = lookup(placement.value, "availability_zone", null)
      group_name        = lookup(placement.value, "group_name", null)
      host_id           = lookup(placement.value, "host_id", null)
      tenancy           = lookup(placement.value, "tenancy", null)
    }
  }

  vpc_security_group_ids = try(each.value.vpc_security_group_ids, null)

  dynamic "network_interfaces" {
    for_each = try(each.value.network_interfaces, {})

    content {
      associate_public_ip_address = try(network_interfaces.value.public_ip, false)
      security_groups             = try(network_interfaces.value.security_groups, null)
    }
  }

  dynamic "monitoring" {
    for_each = try(each.value.monitoring, true) ? [1] : []

    content {
      enabled = true
    }
  }

  dynamic "metadata_options" {
    for_each = try(each.value.enable_metadata_options, true) ? [1] : []

    content {
      http_endpoint               = try(each.value.http_endpoint, "enabled")
      http_tokens                 = try(each.value.http_tokens, "required")
      http_put_response_hop_limit = try(each.value.http_put_response_hop_limit, 2)
      http_protocol_ipv6          = try(each.value.http_protocol_ipv6, "disabled")
      instance_metadata_tags      = try(each.value.instance_metadata_tags, "disabled")
    }
  }

  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume", "network-interface"])

    content {
      resource_type = tag_specifications.value
      tags          = var.tags
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
