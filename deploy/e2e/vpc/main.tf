provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

module "eks-cluster-with-import-vpc" {
  source = "../../../examples/eks-cluster-with-import-vpc/vpc"

  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  region      = var.region

}
