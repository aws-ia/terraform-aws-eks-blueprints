###########
# Namespace
###########

resource "kubernetes_namespace" "namespaces" {
  for_each = var.teams
  metadata {
    name   = each.key
    labels = each.value["labels"]
  }
}

###########
# Quotas
###########

resource "kubernetes_resource_quota" "compute_quotas" {
  for_each = var.teams
  metadata {
    name      = "compute-quota"
    namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
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

resource "kubernetes_resource_quota" "object_quotas" {
  for_each = var.teams
  metadata {
    name      = "object-quota"
    namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
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
# Network Policy
###########

resource "kubernetes_network_policy" "default_deny_all" {
  for_each = var.teams
  metadata {
    name      = "default-deny-all"
    namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
  }

  spec {
    pod_selector {}
    ingress {}
    egress {}
    policy_types = ["Ingress", "Egress"]
  }
}

#TODO we can probably skip proxy config for now.
###########
# Proxy Config
###########

resource "kubernetes_config_map" "proxy_settings" {
  for_each = var.teams
  metadata {
    name      = "proxy-settings"
    namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
  }
  data = {
    HTTP_PROXY  = "@TODO"
    HTTPS_PROXY = "@TODO"
    NO_PROXY    = "@TODO"
  }
}

###########
# IAM / RBAC
###########

data "aws_iam_policy_document" "iam_policy_document" {
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

resource "aws_iam_role" "iam_role_editor" {
  for_each           = var.teams
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document[each.key].json
  # max_session_duration = 43200  
  name = format("%s-%s-%s-%s-%s", var.tenant, var.environment, var.zone,"${each.key}","editor")
  # permissions_boundary = var.permissions_boundary
  tags = var.tags
}

resource "aws_iam_role" "iam_role_reader" {
  for_each           = var.teams
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document[each.key].json
  # max_session_duration = 43200  
  name = format("%s-%s-%s-%s-%s", var.tenant, var.environment, var.zone , "${each.key}","reader")
  # permissions_boundary = var.permissions_boundary
  tags = var.tags
}

resource "kubernetes_role" "k8s_role_editor" {
  for_each = var.teams
  metadata {
    name      = "editor"
    namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
  }
  rule {
    api_groups = ["*"]
    resources  = ["configmaps", "pods", "podtemplates", "secrets", "serviceaccounts", "services", "deployments", "horizontalpodautoscalers", "networkpolicies"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
  rule {
    api_groups = ["*"]
    resources  = ["resourcequotas"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role" "k8s_role_reader" {
  for_each = var.teams
  metadata {
    name      = "reader"
    namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
  }
  rule {
    api_groups = ["*"]
    resources  = ["configmaps", "pods", "podtemplates", "secrets", "serviceaccounts", "services", "deployments", "horizontalpodautoscalers", "networkpolicies"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["*"]
    resources  = ["resourcequotas"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "k8s_role_binding_editor" {
  for_each = var.teams
  metadata {
    name      = "editor"
    namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.k8s_role_editor[each.key].metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "${kubernetes_namespace.namespaces[each.key].metadata[0].name}-editors"
    api_group = "rbac.authorization.k8s.io"
    namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
  }
}

resource "kubernetes_role_binding" "k8s_role_binding_reader" {
  for_each = var.teams
  metadata {
    name      = "reader"
    namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.k8s_role_reader[each.key].metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "${kubernetes_namespace.namespaces[each.key].metadata[0].name}-readers"
    api_group = "rbac.authorization.k8s.io"
    namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
  }
}



# Kubernetes Manifests
resource "kubernetes_manifest" "k8s_manifests" {
  for_each = { for manifest in local.team_manifests: manifest => manifest } 
  manifest = yamldecode(file(each.key))
}