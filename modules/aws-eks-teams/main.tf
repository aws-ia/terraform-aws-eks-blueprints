# ---------------------------------------------------------------------------------------------------------------------
# Namespace
# ---------------------------------------------------------------------------------------------------------------------
resource "kubernetes_namespace" "team" {
  for_each = var.application_teams
  metadata {
    name   = each.key
    labels = try(each.value["labels"], {})
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Quotas
# ---------------------------------------------------------------------------------------------------------------------
resource "kubernetes_resource_quota" "this" {
  for_each = { for team_name, team_data in var.application_teams : team_name => team_data if lookup(team_data, "quota", "") != "" }

  metadata {
    name      = "quotas"
    namespace = kubernetes_namespace.team[each.key].metadata[0].name
  }

  spec {
    hard = try(each.value.quota, {})
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM / RBAC
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "team_access" {
  for_each = { for team_name, team_data in var.application_teams : team_name => team_data if lookup(team_data, "users", "") != "" }

  name                 = "${var.eks_cluster_id}-${each.key}-access"
  permissions_boundary = var.iam_role_permissions_boundary

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

resource "kubernetes_cluster_role" "team" {
  for_each = var.application_teams
  metadata {
    name = "${each.key}-team-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "team" {
  for_each = var.application_teams
  metadata {
    name = "${each.key}-team-cluster-role-binding"
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

resource "kubernetes_role" "team" {
  for_each = var.application_teams
  metadata {
    name      = "${each.key}-role"
    namespace = kubernetes_namespace.team[each.key].metadata[0].name
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

resource "kubernetes_role_binding" "team" {
  for_each = var.application_teams
  metadata {
    name      = "${each.key}-role-binding"
    namespace = kubernetes_namespace.team[each.key].metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${each.key}-role"
  }
  subject {
    kind      = "Group"
    name      = "${each.key}-group"
    api_group = "rbac.authorization.k8s.io"
    namespace = kubernetes_namespace.team[each.key].metadata[0].name
  }
}

resource "aws_iam_role" "team_sa_irsa" {
  for_each = var.application_teams

  name                 = "${var.eks_cluster_id}-${each.key}-sa-role"
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

# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes Team Service Account
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_service_account" "team" {
  for_each = var.application_teams
  metadata {
    name        = format("%s-sa", each.key)
    namespace   = kubernetes_namespace.team[each.key].metadata[0].name
    annotations = { "eks.amazonaws.com/role-arn" : aws_iam_role.team_sa_irsa[each.key].arn }
  }
  automount_service_account_token = true
}

# ---------------------------------------------------------------------------------------------------------------------
# Kubernetes Manifests
# ---------------------------------------------------------------------------------------------------------------------

resource "kubectl_manifest" "team" {
  for_each  = { for manifest in local.team_manifests : manifest => file(manifest) }
  yaml_body = each.value
  depends_on = [
    kubernetes_namespace.team
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Platform Team
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "platform_team" {
  for_each = var.platform_teams

  name                 = "${var.eks_cluster_id}-${each.key}-access"
  permissions_boundary = var.iam_role_permissions_boundary
  managed_policy_arns  = [aws_iam_policy.platform_team_eks_access[0].arn]

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

# ---------------------------------------------------------------------------------------------------------------------
# Platform Team EKS access IAM policy
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "platform_team_eks_access" {
  count       = length(var.platform_teams) > 0 ? 1 : 0
  name        = "${var.eks_cluster_id}-PlatformTeamEKSAccess"
  path        = "/"
  description = "Platform Team EKS Console Access"
  policy      = data.aws_iam_policy_document.platform_team_eks_access[0].json
  tags        = var.tags
}
