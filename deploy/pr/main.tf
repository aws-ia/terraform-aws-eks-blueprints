
terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}

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
  source = "../../examples/advanced/k8s_addons"

  tenant      = "aws"
  environment = "preprod"
  zone        = "pr"

  vpc_id             = data.terraform_remote_state.vpc_s3_backend.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc_s3_backend.outputs.private_subnets
  public_subnet_ids  = data.terraform_remote_state.vpc_s3_backend.outputs.public_subnets
}
