# Namespace
resource "kubernetes_namespace" "application_team_ns" {
  for_each = var.application_teams

  metadata {
    name   = each.key
    labels = try(each.value["labels"], {})
  }
}

# Quotas
resource "kubernetes_resource_quota" "application_team_quota" {
  for_each = var.application_teams

  metadata {
    name      = "quota"
    namespace = kubernetes_namespace.application_team_ns[each.key].metadata[0].name
  }

  spec {
    hard = try(each.value.quota, {})
  }
}

# Application Team EKS Access IAM Role
resource "aws_iam_role" "application_team_iam_role" {
  for_each = { for team_name, team_data in var.application_teams : team_name => team_data if lookup(team_data, "users", "") != "" }

  name                 = "${var.eks_cluster_id}-${each.key}-application-team-iam-role"
  permissions_boundary = var.iam_role_permissions_boundary
  managed_policy_arns  = [aws_iam_policy.application_team_iam_policy[0].arn]

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : each.value.users
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Application Team EKS Access IAM Policy
resource "aws_iam_policy" "application_team_iam_policy" {
  count = length(var.application_teams) > 0 ? 1 : 0

  name        = "${var.eks_cluster_id}-application-team-iam-policy"
  path        = "/"
  description = "Application Team EKS Access IAM Policy"
  policy      = var.application_team_iam_policy

  tags = var.tags
}

resource "kubernetes_cluster_role" "application_team_cluster_role" {
  for_each = var.application_teams

  metadata {
    name = "${each.key}-application-team-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "application_team_cluster_role_binding" {
  for_each = var.application_teams

  metadata {
    name = "${each.key}-application-team-cluster-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${each.key}-team-cluster-role"
  }
  subject {
    kind      = "Group"
    name      = "${each.key}-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role" "application_team_role" {
  for_each = var.application_teams

  metadata {
    name      = "${each.key}-application-team-role"
    namespace = kubernetes_namespace.application_team_ns[each.key].metadata[0].name
  }

  rule {
    api_groups = ["*"]
    resources  = ["configmaps", "pods", "podtemplates", "secrets", "serviceaccounts", "services", "deployments", "horizontalpodautoscalers", "networkpolicies", "statefulsets", "replicasets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["*"]
    resources  = ["resourcequotas"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "application_team_role_binding" {
  for_each = var.application_teams

  metadata {
    name      = "${each.key}-application-team-role-binding"
    namespace = kubernetes_namespace.application_team_ns[each.key].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${each.key}-role"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "${each.key}-group"
  }
}

resource "aws_iam_role" "application_team_sa_irsa" {
  for_each = var.application_teams

  name                 = "${var.eks_cluster_id}-${each.key}-application-team-sa-role"
  permissions_boundary = var.iam_role_permissions_boundary

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${local.eks_oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${local.eks_oidc_issuer_url}:sub" : "system:serviceaccount:${each.key}:${format("%s-sa", each.key)}",
            "${local.eks_oidc_issuer_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}


# Application Team Service Account
resource "kubernetes_service_account" "application_team_sa" {
  for_each = var.application_teams

  metadata {
    name        = format("%s-sa", each.key)
    namespace   = kubernetes_namespace.application_team_ns[each.key].metadata[0].name
    annotations = { "eks.amazonaws.com/role-arn" : aws_iam_role.application_team_sa_irsa[each.key].arn }
  }
}

# Kubernetes Manifests
resource "kubectl_manifest" "application_team_manifest" {
  for_each = { for manifest in local.application_team_manifests : manifest => file(manifest) }

  yaml_body = each.value

  depends_on = [
    kubernetes_namespace.application_team_ns
  ]
}

# Platform Team EKS Access IAM Role
resource "aws_iam_role" "platform_team_iam_role" {
  for_each = var.platform_teams

  name                 = "${var.eks_cluster_id}-${each.key}-platform-team-iam-role"
  permissions_boundary = var.iam_role_permissions_boundary
  managed_policy_arns  = [aws_iam_policy.platform_team_iam_policy[0].arn]

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : each.value.users
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Platform Team EKS Access IAM policy
resource "aws_iam_policy" "platform_team_iam_policy" {
  count = length(var.platform_teams) > 0 ? 1 : 0

  name        = "${var.eks_cluster_id}-platform-team-iam-policy"
  path        = "/"
  description = "Platform Team EKS Access IAM Policy"
  policy      = data.aws_iam_policy_document.platform_team_iam_policy[0].json

  tags = var.tags
}
