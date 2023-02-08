locals {
  eks_oidc_issuer_url = replace(var.eks_oidc_provider_arn, "/^(.*provider/)/", "")

  # This regex is from RFC 1123 where the subdomain must consist of lower case alphanumeric characters, -, or .
  # The regex was slightly modified to add the additional beginning capture group to contain the first char and
  # use a double backslash as needed by terraform.
  # This is required if using a wildcard in var.kubernetes_service_account in order to provide the correct input
  # to kubernetes_service_account_v1.metadata.name.
  kubernetes_service_account = join("", compact(
    regex("([a-z0-9])([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*", var.kubernetes_service_account)
  ))
}

resource "kubernetes_namespace_v1" "irsa" {
  count = var.create_kubernetes_namespace && var.kubernetes_namespace != "kube-system" ? 1 : 0
  metadata {
    name = var.kubernetes_namespace
  }

  timeouts {
    delete = "15m"
  }
}

resource "kubernetes_secret_v1" "irsa" {
  count = var.create_kubernetes_service_account && var.create_service_account_secret_token ? 1 : 0
  metadata {
    name      = format("%s-token-secret", try(kubernetes_service_account_v1.irsa[0].metadata[0].name, local.kubernetes_service_account))
    namespace = try(kubernetes_namespace_v1.irsa[0].metadata[0].name, var.kubernetes_namespace)
    annotations = {
      "kubernetes.io/service-account.name"      = try(kubernetes_service_account_v1.irsa[0].metadata[0].name, local.kubernetes_service_account)
      "kubernetes.io/service-account.namespace" = try(kubernetes_namespace_v1.irsa[0].metadata[0].name, var.kubernetes_namespace)
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_service_account_v1" "irsa" {
  count = var.create_kubernetes_service_account ? 1 : 0
  metadata {
    name        = local.kubernetes_service_account
    namespace   = try(kubernetes_namespace_v1.irsa[0].metadata[0].name, var.kubernetes_namespace)
    annotations = var.irsa_iam_policies != null ? { "eks.amazonaws.com/role-arn" : aws_iam_role.irsa[0].arn } : null
  }

  dynamic "image_pull_secret" {
    for_each = var.kubernetes_svc_image_pull_secrets != null ? var.kubernetes_svc_image_pull_secrets : []
    content {
      name = image_pull_secret.value
    }
  }

  automount_service_account_token = true
}

# NOTE: Don't change the condition from StringLike to StringEquals. We are using wild characters for service account hence StringLike is required.
resource "aws_iam_role" "irsa" {
  count = var.irsa_iam_policies != null ? 1 : 0

  name        = try(coalesce(var.irsa_iam_role_name, format("%s-%s-%s", var.eks_cluster_id, local.kubernetes_service_account, "irsa")), null)
  description = "AWS IAM Role for the Kubernetes service account ${var.kubernetes_service_account}."
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.eks_oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringLike" : {
            "${local.eks_oidc_issuer_url}:sub" : "system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account}",
            "${local.eks_oidc_issuer_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  path                  = var.irsa_iam_role_path
  force_detach_policies = true
  permissions_boundary  = var.irsa_iam_permissions_boundary

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "irsa" {
  count = var.irsa_iam_policies != null ? length(var.irsa_iam_policies) : 0

  policy_arn = var.irsa_iam_policies[count.index]
  role       = aws_iam_role.irsa[0].name
}
