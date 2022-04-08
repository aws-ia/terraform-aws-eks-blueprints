provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

module "e2e-test" {
  source = "../../../EXAMPLE_PATH"

  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone

}
