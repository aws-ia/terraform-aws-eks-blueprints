module "helm_addon" {
  source               = "../helm-addon"
  helm_config          = local.helm_config
  irsa_config          = null
  set_sensitive_values = local.set_sensitive
  addon_context        = var.addon_context

  depends_on = [kubernetes_namespace_v1.this]
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = local.helm_config["namespace"]

    labels = {
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
    }
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# ArgoCD App of Apps Bootstrapping
# ---------------------------------------------------------------------------------------------------------------------
resource "helm_release" "argocd_application" {
  for_each = { for k, v in var.applications : k => merge(local.default_argocd_application, v) }

  name      = each.key
  chart     = "${path.module}/argocd-application"
  version   = "1.0.0"
  namespace = local.helm_config["namespace"]

  # Application Meta.
  set {
    name  = "name"
    value = each.key
  }

  set {
    name  = "project"
    value = each.value.project
  }

  # Source Config.
  set {
    name  = "source.repoUrl"
    value = each.value.repo_url
  }

  set {
    name  = "source.targetRevision"
    value = each.value.target_revision
  }

  set {
    name  = "source.path"
    value = each.value.path
  }

  set {
    name  = "source.helm.releaseName"
    value = each.key
  }

  set {
    name = "source.helm.values"
    value = yamlencode(merge(
      { repo_url = each.value.repo_url },
      each.value.values,
      local.global_application_values,
      each.value.add_on_application ? var.addon_config : {}
    ))
  }

  # Destination Config.
  set {
    name  = "destination.server"
    value = each.value.destination
  }

  depends_on = [module.helm_addon]
}

# ---------------------------------------------------------------------------------------------------------------------
# Private Repo Access
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_secret" "argocd_gitops" {
  for_each = { for k, v in var.applications : k => v if try(v.ssh_key_secret_name, null) != null }

  metadata {
    name      = "${each.key}-repo-secret"
    namespace = local.helm_config["namespace"]
    labels    = { "argocd.argoproj.io/secret-type" : "repository" }
  }

  data = {
    type          = "git"
    url           = each.value.repo_url
    sshPrivateKey = data.aws_secretsmanager_secret_version.ssh_key_version[each.key].secret_string
  }

  depends_on = [module.helm_addon]
}
