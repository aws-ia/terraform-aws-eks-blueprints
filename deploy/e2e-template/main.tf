provider "aws" {
  region = "us-west-2"
}

module "e2e_test" {
  source = "../../../EXAMPLE_PATH"
}
