# Current version of integrations/github has a bug.
# The "provider" block needs to be set in the module.
provider "github" {
  owner = var.provider_owner
  token = var.provider_token
}

# Using 2 separate resources, because 
# variable usage in lifecycle block is not available yet.

resource "github_repository" "loosely_coupled" {
  count = var.loose_coupling ? 1 : 0

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

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository" "tightly_coupled" {
  count = !var.loose_coupling ? 1 : 0

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

  lifecycle {
    prevent_destroy = false
  }
}