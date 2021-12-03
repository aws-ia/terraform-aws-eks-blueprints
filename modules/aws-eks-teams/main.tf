# ---------------------------------------------------------------------------------------------------------------------
# Namespace
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_namespace" "team" {
  for_each = var.application_teams
  metadata {
    name   = each.key
    labels = each.value["labels"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Quotas
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_resource_quota" "team_compute_quota" {
  for_each = var.application_teams
  metadata {
    name      = "compute-quota"
    namespace = kubernetes_namespace.team[each.key].metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = each.value["quota"]["requests.cpu"]
      "requests.memory" = each.value["quota"]["requests.memory"]
      "limits.cpu"      = each.value["quota"]["limits.cpu"]
      "limits.memory"   = each.value["quota"]["limits.memory"]
    }
  }
}

resource "kubernetes_resource_quota" "team_object_quota" {
  for_each = var.application_teams
  metadata {
    name      = "object-quota"
    namespace = kubernetes_namespace.team[each.key].metadata[0].name
  }
  spec {
    hard = {
      "pods"     = each.value["quota"]["pods"]
      "secrets"  = each.value["quota"]["secrets"]
      "services" = each.value["quota"]["services"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM / RBAC
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "team_access" {
  for_each = { for team_name, team_data in var.application_teams : team_name => team_data if lookup(team_data, "users", "") != "" }
  name     = format("%s-%s-%s", local.role_prefix_name, "${each.key}", "Access")
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
  name     = format("%s-%s-%s", local.role_prefix_name, "${each.key}", "sa-role")
  tags     = var.tags
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

resource "kubernetes_manifest" "team" {
  for_each = { for manifest in local.team_manifests : manifest => manifest }
  manifest = yamldecode(file(each.key))
}

# ---------------------------------------------------------------------------------------------------------------------
# Platform Team
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "platform_team" {
  for_each            = var.platform_teams
  name                = format("%s-%s-%s", local.role_prefix_name, "${each.key}", "Access")
  tags                = var.tags
  managed_policy_arns = [aws_iam_policy.platform_team_eks_access.arn]
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
}

# ---------------------------------------------------------------------------------------------------------------------
# Platform Team EKS access IAM policy
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "platform_team_eks_access" {
  name        = format("%s-%s", local.role_prefix_name, "PlatformTeamEKSAccess")
  path        = "/"
  description = "Platform Team EKS Console Access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "ssm:GetParameter",
          "eks:ListUpdates",
          "eks:ListFargateProfiles"
        ]
        Effect   = "Allow"
        Resource = data.aws_eks_cluster.eks_cluster.arn
        }, {
        Action = [
          "eks:ListClusters",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
