provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

module "eks-cluster-with-import-vpc" {
  source = "../../../examples/eks-cluster-with-import-vpc/eks"

  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  region      = var.region

  # VPC S3 TF State
  tf_state_vpc_s3_bucket = var.tf_state_vpc_s3_bucket
  tf_state_vpc_s3_key    = var.tf_state_vpc_s3_key

}
