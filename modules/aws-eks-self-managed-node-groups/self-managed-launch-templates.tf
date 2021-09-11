resource "aws_launch_template" "self_managed_ng" {
  name_prefix            = format("%s%s", "${var.cluster_full_name}-${local.self_managed_nodegroup_name}", "-")
  instance_type          = local.self_managed_node_instance_type
  image_id               = local.self_managed_node_ami_id
  vpc_security_group_ids = var.custom_security_group_id == "" ? [aws_security_group.self_managed_ng[0].id] : [var.custom_security_group_id]
  //  user_data               = base64encode(
  //  templatefile("${path.module}/templates/userdata-${local.custom_ami_type}.tpl", local.userdata_params)
  //  )

  user_data = local.custom_userdata_base64


  dynamic "instance_market_options" {
    for_each = local.self_managed_capacity_type == "spot" ? [1] : []
    content {
      market_type = local.self_managed_capacity_type
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.self_managed_ng.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "gp2"
      volume_size           = local.self_managed_node_volume_size
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.common_tags
  }
}