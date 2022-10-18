provider "github" {
  owner = var.provider_owner
  token = var.provider_token
}

resource "github_repository" "repository" {
  count = var.loose_coupling ? 0 : 1

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

resource "null_resource" "run_module_separately" {
  count = var.loose_coupling ? 1 : 0

  // Run terraform apply if it was not run previously
  provisioner "local-exec" {
    command = <<EOT
      if [ ! -f "${path.module}/was_run" ]; then
          terraform -chdir="${path.module}" init -upgrade && terraform -chdir="${path.module}" apply -auto-approve && \
          touch ${path.module}/was_run
      fi
    EOT

    environment = {
      TF_VAR_name = "${var.name}"
      TF_VAR_description = "${var.description}"
      TF_VAR_visibility = "${var.visibility}"
      TF_VAR_template_owner = "${var.template_owner}"
      TF_VAR_template_repo_name = "${var.template_repo_name}"
      TF_VAR_provider_owner = "${var.provider_owner}"
      TF_VAR_provider_token = "${var.provider_token}"
      TF_VAR_loose_coupling = "false"
    }
  }
}

resource "null_resource" "delete_flag_file" {
  count = var.loose_coupling ? 0 : 1
  
  // If "was_run" file exists, delete it on destroy
  provisioner "local-exec" {
    command = <<EOT
      if [ -f "was_run" ]; then
          rm was_run || true
      fi
    EOT
    when = destroy
  }
}