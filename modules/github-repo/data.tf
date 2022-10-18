data "terraform_remote_state" "state_file" {
  count = var.loose_coupling ? 1 : 0

  backend = "local"

  config = {
    path = "./terraform.tfstate"
  }

  depends_on = [
    null_resource.run_module_separately
  ]
}