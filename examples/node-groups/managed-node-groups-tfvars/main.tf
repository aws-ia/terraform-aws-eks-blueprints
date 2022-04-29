provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

data "aws_availability_zones" "available" {}

#------------------------------------------------------------------------
# Local Variables
#------------------------------------------------------------------------
locals {
  count_availability_zone = (length(data.aws_availability_zones.available.names) <= 3) ? length(data.aws_availability_zones.available.zone_ids) : 3
  azs                     = slice(data.aws_availability_zones.available.names, 0, local.count_availability_zone)
  vpc_name                = join("-", [var.tenant, var.environment, var.zone, "vpc"])
  cluster_name            = join("-", [var.tenant, var.environment, var.zone, "eks"])
  region                  = "us-west-2"
}
