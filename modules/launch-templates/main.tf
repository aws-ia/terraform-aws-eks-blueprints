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

data "template_file" "launch_template_userdata" {
  template = file("${path.module}/templates/userdata.sh.tpl")
}

data "template_file" "launch_template_bottle_rocket_userdata" {
  template = file("${path.module}/templates/bottlerocket-userdata.sh.tpl")
  vars = {
    cluster_endpoint    = var.cluster_endpoint
    cluster_auth_base64 = var.cluster_auth_base64
    cluster_name        = var.cluster_name
  }
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

  image_id = var.self_managed ? var.bottlerocket_ami : ""
  //  instance_type = var.instance_type

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, tomap({"Name" = "${var.cluster_name}-${var.node_group_name}"}))
  }

  network_interfaces {
    associate_public_ip_address = var.public_launch_template ? true : false
    delete_on_termination       = true
    security_groups             = [var.worker_security_group_id]
  }

  user_data = var.self_managed ? base64encode(
    data.template_file.launch_template_bottle_rocket_userdata.rendered,
    ) : base64encode(
    data.template_file.launch_template_userdata.rendered,
  )

  lifecycle {
    create_before_destroy = true
  }
}