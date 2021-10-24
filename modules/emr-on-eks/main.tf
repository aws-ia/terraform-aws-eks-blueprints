data "aws_region" "current" {}

resource "kubernetes_namespace" "spark" {
  metadata {
    annotations = {
      name = local.emr_on_eks_team["emr_on_eks_namespace"]
    }

    labels = {
      job-type = "spark"
    }

    name = local.emr_on_eks_team["emr_on_eks_namespace"]
  }
}

resource "kubernetes_role" "emr_containers" {
  metadata {
    name      = local.emr_on_eks_team["emr_on_eks_username"]
    namespace = kubernetes_namespace.spark.id
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "list", "watch", "describe", "create", "edit", "delete", "deletecollection", "annotate", "patch", "label"]
    api_groups = [""]
    resources  = ["serviceaccounts", "services", "configmaps", "events", "pods", "pods/log"]
  }

  rule {
    verbs      = ["create", "patch", "delete", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["get", "list", "watch", "describe", "create", "edit", "delete", "annotate", "patch", "label"]
    api_groups = ["apps"]
    resources  = ["statefulsets", "deployments"]
  }

  rule {
    verbs      = ["get", "list", "watch", "describe", "create", "edit", "delete", "annotate", "patch", "label"]
    api_groups = ["batch"]
    resources  = ["jobs"]
  }

  rule {
    verbs      = ["get", "list", "watch", "describe", "create", "edit", "delete", "annotate", "patch", "label"]
    api_groups = ["extensions"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["get", "list", "watch", "describe", "create", "edit", "delete", "deletecollection", "annotate", "patch", "label"]
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings"]
  }
}

resource "kubernetes_role_binding" "emr_containers" {
  metadata {
    name      = local.emr_on_eks_team["emr_on_eks_username"]
    namespace = kubernetes_namespace.spark.id
  }

  subject {
    kind = "User"
    name = local.emr_on_eks_team["emr_on_eks_username"]
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = local.emr_on_eks_team["emr_on_eks_username"]
  }
}


# EMR jobs will assume this IAM role when they run on EKS
resource "aws_iam_role" "emr_on_eks_execution" {
  name               = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, local.emr_on_eks_team["emr_on_eks_iam_role_name"])
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "elasticmapreduce.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
EOF
}

resource "aws_iam_policy" "emr_on_eks_execution" {
  name        = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, local.emr_on_eks_team["emr_on_eks_iam_role_name"])
  description = "Allows role to generate kubeconfig for Kubectl access"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "emr_on_eks_execution" {
  role       = aws_iam_role.emr_on_eks_execution.name
  policy_arn = aws_iam_policy.emr_on_eks_execution.arn
}

# TODO Replace this resource once the provider is available for aws emr-containers
resource "null_resource" "update_trust_policy" {
  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    environment = {
      AWS_DEFAULT_REGION = data.aws_region.current.id
    }
    command = <<EOF
set -e

aws emr-containers update-role-trust-policy \
--cluster-name ${var.eks_cluster_id} \
--namespace ${kubernetes_namespace.spark.id} \
--role-name ${aws_iam_role.emr_on_eks_execution.id}

EOF
  }
  triggers = {
    always_run = timestamp()
  }
  depends_on = [kubernetes_namespace.spark, aws_iam_role.emr_on_eks_execution]
}
