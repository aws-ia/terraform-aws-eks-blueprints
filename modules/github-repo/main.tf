locals {
  template_owner = var.template_owner == "" ? var.provider_owner : var.template_owner
}

# Current version of integrations/github has a bug.
# The "provider" block needs to be set in the module.
provider "github" {
  owner = var.provider_owner
  token = var.provider_token
}

resource "github_repository" "repository" {
  name        = var.name
  description = var.description

  visibility = var.visibility

  dynamic "template" {
    for_each = var.template_repo_name != "" ? [1] : []

    content {
      owner      = local.template_owner
      repository = var.template_repo_name
    }
  }
}