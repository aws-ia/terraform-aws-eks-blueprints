
resource "kubernetes_namespace" "aws_otel_eks" {
  metadata {
    name = var.aws_open_telemetry_namespace

    labels = {
      name = var.aws_open_telemetry_namespace
    }
  }
}

resource "kubernetes_deployment" "aws_otel_eks_sidecar" {
  metadata {
    name      = "aws-otel-eks-sidecar"
    namespace = var.aws_open_telemetry_namespace

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
          name  = var.aws_open_telemetry_emitter_name
          image = var.aws_open_telemetry_emitter_image

          env {
            name  = "OTEL_OTLP_ENDPOINT"
            value = var.aws_open_telemetry_emitter_oltp_endpoint
          }

          env {
            name  = "OTEL_RESOURCE_ATTRIBUTES"
            value = var.aws_open_telemetry_emitter_otel_resource_attributes
          }

          env {
            name  = "S3_REGION"
            value = var.aws_open_telemetry_aws_region
          }

          image_pull_policy = "Always"
        }

        container {
          name  = "aws-otel-collector"
          image = var.aws_open_telemetry_collector_image

          env {
            name  = "AWS_REGION"
            value = var.aws_open_telemetry_aws_region
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
  description = "eks autoscaler policy"

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

resource "aws_iam_role_policy_attachment" "mg-role-policy-attachment" {
  for_each   = toset(var.aws_open_telemetry_mg_node_iam_role_arns)
  role       = each.value
  policy_arn = aws_iam_policy.eks_aws_otel_policy.arn
}

resource "aws_iam_role_policy_attachment" "self-mg-role-policy-attachment" {
  for_each   = toset(var.aws_open_telemetry_self_mg_node_iam_role_arns)
  role       = each.value
  policy_arn = aws_iam_policy.eks_aws_otel_policy.arn
}
