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

resource "aws_eks_fargate_profile" "eks-fargate" {
  cluster_name           = var.eks_cluster_name
  fargate_profile_name   = "${var.eks_cluster_name}-${local.fargate_profiles["fargate_profile_name"]}"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = local.fargate_profiles["subnet_ids"]
  tags = merge(var.tags, local.fargate_profiles["additional_tags"], local.fargate_tags
  )

  dynamic "selector" {
    for_each = toset(local.fargate_profiles["fargate_profile_namespaces"])
    content {
      namespace = selector.value.namespace
      labels    = selector.value.k8s_labels
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.fargate-AmazonEKSFargatePodExecutionRolePolicy,
    //    null_resource.check-namespace
  ]
}

//resource "null_resource" "check-namespace" {
//  for_each = [for s in local.fargate_profiles["fargate_profile_namespaces"] : s]
//
//  provisioner "local-exec" {
//    command = <<SCRIPT
//      var=$(kubectl get namespaces|grep ${each.value.namespace}| wc -l)
//      if [ "$var" -eq "0" ]
//      then kubectl create namespace ${each.value.namespace}
//      else echo '${each.value.namespace} already exists' >&3
//      fi
//    SCRIPT
//  }
//}
