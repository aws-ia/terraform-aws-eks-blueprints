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
    cluster_name         = var.eks_cluster_name
    cluster_ca_base64    = var.cluster_ca_base64
    cluster_endpoint     = var.cluster_endpoint
    bootstrap_extra_args = local.managed_node_group["bootstrap_extra_args"]
    pre_userdata         = local.managed_node_group["pre_userdata"]
    post_userdata        = local.managed_node_group["post_userdata"]
    kubelet_extra_args   = local.managed_node_group["kubelet_extra_args"]
  }

  userdata_base64 = base64encode(
    templatefile("${path.module}/templates/userdata-${local.managed_node_group["custom_ami_type"]}.tpl", local.userdata_params)
  )

}

resource "aws_launch_template" "managed_node_groups" {
  name_prefix            = "${var.eks_cluster_name}-${local.managed_node_group["node_group_name"]}"
  description            = "Launch Template for EKS Managed clusters"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = local.managed_node_group["disk_size"]
      volume_type           = local.managed_node_group["disk_type"]
      delete_on_termination = true
    }
  }

  ebs_optimized = true

  image_id = local.managed_node_group["custom_ami_id"] == "" ? "" : local.managed_node_group["custom_ami_id"]
  //  key_name = local.remote_access_enabled ? var.ec2_ssh_key : null

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, tomap({ "Name" = "${var.eks_cluster_name}-${local.managed_node_group["node_group_name"]}" }))
  }

  network_interfaces {
    associate_public_ip_address = local.managed_node_group["public_ip"]
    security_groups             = [var.worker_security_group_id]
  }

  user_data = local.userdata_base64

  lifecycle {
    create_before_destroy = true
  }
}