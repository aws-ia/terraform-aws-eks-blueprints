# Define terraform state for environment stack

data "terraform_remote_state" "environment" {
  backend = "local"

  config = {
    path = "${path.module}/../environment/terraform.tfstate"
  }
}
