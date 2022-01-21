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

resource "kubernetes_namespace" "aws_otel_eks" {
  count = var.manage_via_gitops ? 0 : 1
  metadata {
    name = local.default_addon_config["namespace"]

    labels = {
      name = local.default_addon_config["namespace"]
    }
  }
}

resource "kubernetes_deployment" "aws_otel_eks_sidecar" {
  count = var.manage_via_gitops ? 0 : 1
  metadata {
    name      = "aws-otel-eks-sidecar"
    namespace = local.default_addon_config["namespace"]

    labels = {
      name = "aws-otel-eks-sidecar"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "aws-otel-eks-sidecar"
      }
    }

    template {
      metadata {
        labels = {
          name = "aws-otel-eks-sidecar"
        }
      }

      spec {
        container {
          name  = local.default_addon_config["emitter_name"]
          image = local.default_addon_config["emitter_image"]

          env {
            name  = "OTEL_OTLP_ENDPOINT"
            value = local.default_addon_config["emitter_oltp_endpoint"]
          }

          env {
            name  = "OTEL_RESOURCE_ATTRIBUTES"
            value = local.default_addon_config["emitter_otel_resource_attributes"]
          }

          env {
            name  = "S3_REGION"
            value = local.default_addon_config["aws_region"]
          }

          image_pull_policy = "Always"
        }

        container {
          name  = "aws-otel-collector"
          image = local.default_addon_config["collector_image"]

          env {
            name  = "AWS_REGION"
            value = local.default_addon_config["aws_region"]
          }

          resources {
            limits = {
              cpu    = "256m"
              memory = "512Mi"
            }

            requests = {
              cpu    = "32m"
              memory = "24Mi"
            }
          }

          image_pull_policy = "Always"
        }
      }
    }
  }
}

resource "aws_iam_policy" "eks_aws_otel_policy" {
  name        = "AWSDistroOpenTelemetryPolicy"
  path        = "/"
  description = "AWS OTEL IAM Policy"
  policy      = data.aws_iam_policy_document.otel.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "node_groups_role_arn" {
  for_each   = toset(var.node_groups_iam_role_arn)
  role       = each.value
  policy_arn = aws_iam_policy.eks_aws_otel_policy.arn
}
