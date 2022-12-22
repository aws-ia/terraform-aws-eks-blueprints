locals {
  name = "gitlab-runner"
}

module "helm_addon" {
  source = "../helm-addon"

  # https://gitlab.com/gitlab-org/charts/gitlab-runner/-/blob/main/Chart.yaml
  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://charts.gitlab.io"
      version          = "0.48.0"
      namespace        = local.name
      create_namespace = true
      description      = "GitLab runner"
      values           = [file("${path.module}/values.yaml")]
    },
    var.helm_config
  )
  manage_via_gitops = var.manage_via_gitops

  addon_context = var.addon_context
}
