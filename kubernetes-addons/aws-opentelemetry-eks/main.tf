
resource "kubernetes_namespace" "aws_otel_eks" {
  count = var.manage_via_gitops ? 0 : 1
  metadata {
    name = local.aws_open_telemetry_app["aws_open_telemetry_namespace"]

    labels = {
      name = local.aws_open_telemetry_app["aws_open_telemetry_namespace"]
    }
  }
}

resource "kubernetes_deployment" "aws_otel_eks_sidecar" {
  count = var.manage_via_gitops ? 0 : 1
  metadata {
    name      = "aws-otel-eks-sidecar"
    namespace = local.aws_open_telemetry_app["aws_open_telemetry_namespace"]

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
          name  = local.aws_open_telemetry_app["aws_open_telemetry_emitter_name"]
          image = local.aws_open_telemetry_app["aws_open_telemetry_emitter_image"]

          env {
            name  = "OTEL_OTLP_ENDPOINT"
            value = local.aws_open_telemetry_app["aws_open_telemetry_emitter_oltp_endpoint"]
          }

          env {
            name  = "OTEL_RESOURCE_ATTRIBUTES"
            value = local.aws_open_telemetry_app["aws_open_telemetry_emitter_otel_resource_attributes"]
          }

          env {
            name  = "S3_REGION"
            value = local.aws_open_telemetry_app["aws_open_telemetry_aws_region"]
          }

          image_pull_policy = "Always"
        }

        container {
          name  = "aws-otel-collector"
          image = local.aws_open_telemetry_app["aws_open_telemetry_collector_image"]

          env {
            name  = "AWS_REGION"
            value = local.aws_open_telemetry_app["aws_open_telemetry_aws_region"]
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

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets",
                "xray:GetSamplingStatisticSummaries",
                "ssm:GetParameters"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "managed_node_role" {
  for_each   = toset(var.aws_open_telemetry_mg_node_iam_role_arns)
  role       = each.value
  policy_arn = aws_iam_policy.eks_aws_otel_policy.arn
}

resource "aws_iam_role_policy_attachment" "self_managed_role" {
  for_each   = toset(var.aws_open_telemetry_self_mg_node_iam_role_arns)
  role       = each.value
  policy_arn = aws_iam_policy.eks_aws_otel_policy.arn
}
