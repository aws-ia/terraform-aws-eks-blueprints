module "helm_addon" {
  source        = "../helm-addon"
  helm_config   = local.helm_config
  irsa_config   = null
  addon_context = var.addon_context

  depends_on = [kubernetes_namespace_v1.this]
}

resource "kubernetes_namespace_v1" "this" {
  count = try(local.helm_config["create_namespace"], true) && local.helm_config["namespace"] != "kube-system" ? 1 : 0
  metadata {
    name = local.helm_config["namespace"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ArgoCD App of Apps Bootstrapping (Helm)
# ---------------------------------------------------------------------------------------------------------------------
resource "helm_release" "argocd_application" {
  for_each = { for k, v in var.applications : k => merge(local.default_argocd_application, v) if merge(local.default_argocd_application, v).type == "helm" }

  name      = each.key
  chart     = "${path.module}/argocd-application/helm"
  version   = "1.0.0"
  namespace = local.helm_config["namespace"]

  # Application Meta.
  set {
    name  = "name"
    value = each.key
    type  = "string"
  }

  set {
    name  = "project"
    value = each.value.project
    type  = "string"
  }

  # Source Config.
  set {
    name  = "source.repoUrl"
    value = each.value.repo_url
    type  = "string"
  }

  set {
    name  = "source.targetRevision"
    value = each.value.target_revision
    type  = "string"
  }

  set {
    name  = "source.path"
    value = each.value.path
    type  = "string"
  }

  set {
    name  = "source.helm.releaseName"
    value = each.key
    type  = "string"
  }

  set {
    name  = "source.helm.values"
    value = data.merge_merge.source_helm_values[each.key].output
    type  = "auto"
  }

  # Destination Config.
  set {
    name  = "destination.server"
    value = each.value.destination
    type  = "string"
  }

  depends_on = [module.helm_addon]
}

# ---------------------------------------------------------------------------------------------------------------------
# ArgoCD App of Apps Bootstrapping (Kustomize)
# ---------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "argocd_kustomize_application" {
  for_each = { for k, v in var.applications : k => merge(local.default_argocd_application, v) if merge(local.default_argocd_application, v).type == "kustomize" }

  yaml_body = templatefile("${path.module}/argocd-application/kubectl/application.yaml.tftpl",
    {
      name                 = each.key
      namespace            = each.value.namespace
      project              = each.value.project
      sourceRepoUrl        = each.value.repo_url
      sourceTargetRevision = each.value.target_revision
      sourcePath           = each.value.path
      destinationServer    = each.value.destination
    }
  )

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
    insecure      = lookup(each.value, "insecure", false)
    sshPrivateKey = data.aws_secretsmanager_secret_version.ssh_key_version[each.key].secret_string
    type          = "git"
    url           = each.value.repo_url
  }

  depends_on = [module.helm_addon]
}

data "merge_merge" "source_helm_values" {
  for_each = { for k, v in var.applications : k => merge(local.default_argocd_application, v) if merge(local.default_argocd_application, v).type == "helm" }

  dynamic "input" {
    for_each = each.value.add_on_application ? ["merge_addon"] : []
    content {
      format = "yaml"
      data   = yamlencode(local.addon_config)
    }
  }

  input {
    format = "yaml"
    data   = yamlencode({ repoUrl = each.value.repo_url })
  }

  input {
    format = "yaml"
    data   = yamlencode(each.value.values)
  }

  input {
    format = "yaml"
    data   = yamlencode(local.global_application_values)
  }

  output_format = "yaml"
}
