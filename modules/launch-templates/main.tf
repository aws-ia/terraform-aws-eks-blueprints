/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
locals {
  userdata_params = {
    cluster_name         = var.cluster_name
    cluster_ca_base64    = var.cluster_ca_base64
    cluster_endpoint     = var.cluster_endpoint
    bootstrap_extra_args = var.bootstrap_extra_args
    pre_userdata         = var.pre_userdata
    post_userdata        = var.post_userdata
    kubelet_extra_args   = var.kubelet_extra_args
  }

  predefined_custom_ami_types = tolist(["amazonlinux2eks", "bottlerocket", "windows"])

  userdata_base64 = {
    for custom_ami_type in local.predefined_custom_ami_types : custom_ami_type => base64encode(
      templatefile(
        "${path.module}/templates/userdata-${custom_ami_type}.tpl",
        local.userdata_params
      )
    )
  }

  custom_userdata_base64 = var.use_custom_ami ? contains(local.predefined_custom_ami_types, var.custom_ami_type) ? local.userdata_base64[var.custom_ami_type] : base64encode(
    templatefile(var.custom_userdata_template_filepath, merge(local.userdata_params, var.custom_userdata_template_params))
  ) : null
}

resource "aws_launch_template" "default" {
  name_prefix            = "${var.cluster_name}-${var.node_group_name}"
  description            = "Launch Template for EKS Managed clusters"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  ebs_optimized = true

  image_id = var.use_custom_ami ? var.custom_ami_id : ""
  //  instance_type = var.instance_type

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, tomap({ "Name" = "${var.cluster_name}-${var.node_group_name}" }))
  }

  network_interfaces {
    associate_public_ip_address = var.public_launch_template ? true : false
    delete_on_termination       = true
    security_groups             = [var.worker_security_group_id]
  }

  user_data = var.use_custom_ami ? local.custom_userdata_base64 : null

  lifecycle {
    create_before_destroy = true
  }
}