

terraform {
  backend "s3" {
    bucket = "terraform-state-327949925549"
    key    = "pr/eks/terraform-main.tfstate"
    region = "eu-west-1"
  }
}
# Importing VPC remote state config
data "terraform_remote_state" "vpc_s3_backend" {
  backend = "s3"
  config = {
    bucket = "terraform-state-327949925549"
    key    = "e2e/vpc/terraform-main.tfstate"
    region = "eu-west-1"
  }
}

module "eks-cluster-with-import-vpc" {
  source = "../../deploy/advanced/k8s_addons"

  tenant = "aws"
  environment = "preprod"
  zone = "pr"

  vpc_id = data.terraform_remote_state.vpc_s3_backend.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc_s3_backend.outputs.private_subnets
  public_subnet_ids = data.terraform_remote_state.vpc_s3_backend.outputs.public_subnets

}
