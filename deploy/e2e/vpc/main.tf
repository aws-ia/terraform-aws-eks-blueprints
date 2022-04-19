provider "aws" {
  region = "us-west-2"
}

module "eks_cluster_with_import_vpc" {
  source = "../../../examples/eks-cluster-with-import-vpc/vpc"

  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
}
