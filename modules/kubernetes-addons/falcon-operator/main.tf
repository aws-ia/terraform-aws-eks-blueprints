locals {
  name = "falcon-operator"
}

module "falcon_operator" {
  source = "github.com/crowdstrike/terraform-modules//falcon/operator?ref=main"

  client_id = var.client_id
  client_secret = var.client_secret
  sensor_type = var.sensor_type
  environment = var.environment
}
