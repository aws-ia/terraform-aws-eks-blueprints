###########
# Namespace
###########

resource "kubernetes_namespace" "team" {
  for_each = var.teams
  metadata {
    name   = each.key
    labels = each.value["labels"]
  }
}

###########
# Quotas
###########

resource "kubernetes_resource_quota" "team_compute_quota" {
  for_each = var.teams
  metadata {
    name      = "compute-quota"
    namespace = each.key
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
  for_each = var.teams
  metadata {
    name      = "object-quota"
    namespace = each.key
  }
  spec {
    hard = {
      "pods"     = each.value["quota"]["pods"]
      "secrets"  = each.value["quota"]["secrets"]
      "services" = each.value["quota"]["services"]
    }
  }
}

###########
# IAM / RBAC
###########

data "aws_iam_policy_document" "team_access" {
  for_each = var.teams
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)
      ]
    }
  }
}
resource "aws_iam_role" "team_access" {
  for_each           = var.teams
  assume_role_policy = data.aws_iam_policy_document.team_access[each.key].json
  name               = format("%s-%s-%s-%s-%s", var.tenant, var.environment, var.zone, "${each.key}", "access")
  tags               = var.tags
}

resource "kubernetes_cluster_role" "team" {
  for_each = var.teams
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
  for_each = var.teams
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
  for_each = var.teams
  metadata {
    name      = "${each.key}-role"
    namespace = each.key
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
  for_each = var.teams
  metadata {
    name      = "${each.key}-role-binding"
    namespace = each.key
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
    namespace = each.key
  }
}


resource "aws_iam_role" "team_sa_irsa" {
  for_each = var.teams
  name     = format("%s-%s-%s-%s-%s", var.tenant, var.environment, var.zone, "${each.key}", "saRole")
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


# Kubernetes Team Service Account
resource "kubernetes_service_account" "team" {
  for_each = var.teams
  metadata {
    name        = format("%s-sa", each.key)
    namespace   = each.key
    annotations = { "eks.amazonaws.com/role-arn" : aws_iam_role.team_sa_irsa[each.key].arn }
  }
  automount_service_account_token = true
}

# Kubernetes Manifests
resource "kubernetes_manifest" "team" {
  for_each = { for manifest in local.team_manifests : manifest => manifest }
  manifest = yamldecode(file(each.key))
}
