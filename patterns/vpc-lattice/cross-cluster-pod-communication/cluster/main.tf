provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  #Do not include local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

locals {
  #TODO Change this
  name   = "eks-${terraform.workspace}"
  region = "eu-west-1"

  cluster_vpc_cidr = "10.0.0.0/16"
  azs              = slice(data.aws_availability_zones.available.names, 0, 3)

  domain          = data.terraform_remote_state.environment.outputs.custom_domain_name
  certificate_arn = data.terraform_remote_state.environment.outputs.aws_acm_cert_arn
  acmpca_arn      = data.terraform_remote_state.environment.outputs.aws_acmpca_cert_authority_arn
  custom_domain   = data.terraform_remote_state.environment.outputs.custom_domain_name

  app_namespace = "apps"

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}
