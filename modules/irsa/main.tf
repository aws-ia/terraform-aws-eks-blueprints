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

resource "kubernetes_namespace_v1" "irsa" {
  count = var.create_kubernetes_namespace ? 1 : 0
  metadata {
    name = var.kubernetes_namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform-ssp-amazon-eks"
    }
  }
}

resource "kubernetes_service_account_v1" "irsa" {
  count = var.create_kubernetes_service_account ? 1 : 0
  metadata {
    name        = var.kubernetes_service_account
    namespace   = var.kubernetes_namespace
    annotations = var.irsa_iam_policies != null ? { "eks.amazonaws.com/role-arn" : aws_iam_role.irsa[0].arn } : null
    labels = {
      "app.kubernetes.io/managed-by" = "terraform-ssp-amazon-eks"
    }
  }

  automount_service_account_token = true
}

resource "aws_iam_role" "irsa" {
  count = var.irsa_iam_policies != null ? 1 : 0

  name        = format("%s-%s-%s", var.addon_context.eks_cluster_id, trim(var.kubernetes_service_account, "-*"), "irsa")
  description = "AWS IAM Role for the Kubernetes service account ${var.kubernetes_service_account}."
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${var.addon_context.eks_oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${var.addon_context.eks_oidc_issuer_url}:sub" : "system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account}"
          }
        }
      }
    ]
  })
  path                  = var.iam_role_path
  force_detach_policies = true
  permissions_boundary  = var.irsa_iam_permissions_boundary

  tags = merge(
    {
      "Name"                         = format("%s-%s-%s", var.addon_context.eks_cluster_id, trim(var.kubernetes_service_account, "-*"), "irsa"),
      "app.kubernetes.io/managed-by" = "terraform-ssp-amazon-eks"
    },
    var.addon_context.tags
  )
}

resource "aws_iam_role_policy_attachment" "irsa" {
  count = var.irsa_iam_policies != null ? length(var.irsa_iam_policies) : 0

  policy_arn = var.irsa_iam_policies[count.index]
  role       = aws_iam_role.irsa[0].name
}
