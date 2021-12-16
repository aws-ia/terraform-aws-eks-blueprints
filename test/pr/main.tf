

terraform {
  backend "s3" {
    bucket = "terraform-ssp-github-actions-state"
    key    = "pr/eks/terraform-main.tfstate"
    region = "us-west-2"
  }
}
# Importing VPC remote state config
data "terraform_remote_state" "vpc_s3_backend" {
  backend = "s3"
  config = {
    bucket = "terraform-ssp-github-actions-state"
    key    = "e2e/vpc/terraform-main.tfstate"
    region = "us-west-2"
  }
}

module "eks-cluster-with-import-vpc" {
  source = "../../deploy/2-eks-cluster-with-import-vpc/eks"

  tenant = "aws"
  environment = "preprod"
  zone = "pr"

  vpc_id = data.terraform_remote_state.vpc_s3_backend.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc_s3_backend.outputs.private_subnets
  public_subnet_ids = data.terraform_remote_state.vpc_s3_backend.outputs.public_subnets

}
