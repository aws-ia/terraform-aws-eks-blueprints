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
  default_fargate_profiles = {
    fargate_profile_name          = "default"
    fargate_profile_namespaces    = {}
    create_iam_role               = "false"
    subnet_type                   = "private"
    k8s_labels                    = {}
    k8s_taints                    = []
    additional_tags               = {}
    additional_security_group_ids = []
    source_security_group_ids     = ""
  }
  fargate_profiles = merge(
    local.default_fargate_profiles,
    var.fargate_profile,
    { subnet_ids = var.fargate_profile["subnet_ids"] == [] ? var.fargate_profile["subnet_type"] == "public" ? var.public_subnet_ids : var.private_subnet_ids : var.fargate_profile["subnet_ids"] }
  )


  fargate_tags = merge(
    { "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" },
  { "k8s.io/cluster/${var.eks_cluster_name}" = "owned" })

}
