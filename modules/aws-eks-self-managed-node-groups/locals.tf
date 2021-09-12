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

  default_self_managed_ng = {
    node_group_name               = "m4_on_demand"
    desired_size                  = "1"
    instance_type                 = "m4.large"
    key_name                      = ""
    launch_template_id            = null
    launch_template_version       = "$Latest"
    max_size                      = "3"
    min_size                      = "1"
    max_unavailable               = "1"
    kubelet_extra_args            = ""
    bootstrap_extra_args          = ""
    disk_size                     = 50
    disk_type                     = "gp2"
    enable_monitoring             = true
    eni_delete                    = true
    public_ip                     = false
    pre_userdata                  = ""
    post_userdata                 = ""
    additional_security_group_ids = []
    capacity_type                 = ""
    ami_type                      = ""
    create_launch_template        = false
    subnet_type                   = "private"
    k8s_labels                    = {}
    k8s_taints                    = []
    remote_access                 = false
    ec2_ssh_key                   = ""
    security_group_id             = ""
    additional_tags               = {}
    os_ami_type                   = "amazonlinux2eks"
    custom_ami_id                 = ""
    create_worker_security_group  = false
  }

  self_managed_node_group = merge(
    local.default_self_managed_ng,
    var.self_managed_ng,
    { subnet_ids = var.self_managed_ng["subnet_ids"] == [] ? var.self_managed_ng["subnet_type"] == "public" ? var.public_subnet_ids : var.private_subnet_ids : var.self_managed_ng["subnet_ids"] }
  )

  predefined_custom_ami_types = tolist(["amazonlinux2eks", "bottlerocket", "windows"])

  userdata_base64 = {
    for os_ami_type in local.predefined_custom_ami_types : os_ami_type => base64encode(
      templatefile(
        "${path.module}/templates/userdata-${os_ami_type}.tpl",
        local.userdata_params
      )
    )
  }

  custom_userdata_base64 = contains(local.predefined_custom_ami_types, local.self_managed_node_group["os_ami_type"]) ? local.userdata_base64[local.self_managed_node_group["os_ami_type"]] : null

  userdata_params = {
    cluster_name         = var.eks_cluster_name
    cluster_ca_base64    = var.cluster_ca_base64
    cluster_endpoint     = var.cluster_endpoint
    bootstrap_extra_args = local.self_managed_node_group["bootstrap_extra_args"]
    pre_userdata         = local.self_managed_node_group["pre_userdata"]
    post_userdata        = local.self_managed_node_group["post_userdata"]
    kubelet_extra_args   = local.self_managed_node_group["kubelet_extra_args"]
  }

  policy_arn_prefix = "arn:aws:iam::aws:policy"
  ec2_principal     = "ec2.${data.aws_partition.current.dns_suffix}"

  common_tags = merge(
    var.tags,
    {
      Name                                                = "${var.eks_cluster_name}-${local.self_managed_node_group["node_group_name"]}"
      "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"                 = "TRUE"
      "kubernetes.io/cluster/${var.eks_cluster_name}"     = "owned"
  })

}
