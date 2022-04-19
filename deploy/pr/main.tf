# Importing VPC remote state config
data "terraform_remote_state" "vpc_s3_backend" {
  backend = "s3"
  config = {
    bucket = "terraform-ssp-github-actions-state"
    key    = "e2e/vpc/terraform-main.tfstate"
    region = "us-west-2"
  }
}

module "eks_cluster_with_import_vpc" {
  source = "../../examples/complete-kubernetes-addons"

  tenant      = "aws"
  environment = "preprod"
  zone        = "pr"

  vpc_id             = data.terraform_remote_state.vpc_s3_backend.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc_s3_backend.outputs.private_subnets
}
