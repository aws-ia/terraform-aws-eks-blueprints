
#---------------------------------------------------------------
# NOTE: The following resources shows an example of
#        how to read remote state file and import the resources e.g., vpc_id, subnet ids etc..
#---------------------------------------------------------------

/*
#---------------------------------------------------------------
# Example: terraform_remote_state for local backend
#---------------------------------------------------------------
data "terraform_remote_state" "vpc_local_backend" {
  backend = "local"
  config = {
    path = "./local_tf_state/ekscluster/preprod/application/test/vpc/terraform-main.tfstate"
  }
}

#---------------------------------------------------------------
# Example: terraform_remote_state for S3 backend
#---------------------------------------------------------------
data "terraform_remote_state" "vpc_s3_backend" {
  backend = "s3"
  config = {
    bucket = ""     # Bucket name
    key = ""        # Key path to terraform-main.tfstate file
    region = ""     # aws region
  }
}


#---------------------------------------------------------------
# Example to consume aws-eks-accelerator-for-terraform module
#---------------------------------------------------------------
module "aws-eks-accelerator-for-terraform" {
  source = "git@github.com:aws-samples/aws-eks-accelerator-for-terraform.git"

  create_vpc           = false
  create_vpc_endpoints = false

  vpc_id               = data.terraform_remote_state.vpc_local_backend.outputs.vpc_id
  private_subnet_ids   = data.terraform_remote_state.vpc_local_backend.outputs.private_subnets
  public_subnet_ids    = data.terraform_remote_state.vpc_local_backend.outputs.public_subnets

}
*/