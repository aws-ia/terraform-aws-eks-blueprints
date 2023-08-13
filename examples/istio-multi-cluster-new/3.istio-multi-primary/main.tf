# provider "aws" {
#   region = local.region
# }

data "aws_availability_zones" "available" {}

# locals {
#   cluster_name = format("%s-%s", basename(path.cwd), "shared")
#   region       = "eu-west-1"

#   vpc_cidr = "10.0.0.0/16"
#   azs      = slice(data.aws_availability_zones.available.names, 0, 3)

#   istio_chart_url     = "https://istio-release.storage.googleapis.com/charts"
#   istio_chart_version = "1.18.1"

#   tags = {
#     Blueprint  = local.cluster_name
#     GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
#   }
# }

locals {
  cluster1_name = data.terraform_remote_state.cluster1.outputs.cluster_name
  cluster2_name = data.terraform_remote_state.cluster2.outputs.cluster_name

}

################################################################################
# Remote states and Kubernetes providers for VPCs and Clusters
################################################################################

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../0.vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "cluster1" {
  backend = "local"

  config = {
    path = "${path.module}/../1.cluster1/terraform.tfstate"
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.cluster1.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster1.outputs.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.cluster1.outputs.cluster_name, "--region", data.terraform_remote_state.cluster1.outputs.cluster_region]
  }
  alias = "cluster1"
}

data "terraform_remote_state" "cluster2" {
  backend = "local"

  config = {
    path = "${path.module}/../2.cluster2/terraform.tfstate"
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.cluster2.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster2.outputs.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.cluster2.outputs.cluster_name, "--region", data.terraform_remote_state.cluster2.outputs.cluster_region]
  }
  alias = "cluster2"
}

# Istio secret

################################################################################
# Istio remote secret for cluster 1 (istioctl x create-remote-secret)
################################################################################

resource "kubernetes_secret" "istio_remote_secret_cluster2" {
  provider = kubernetes.cluster1

  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = "istio-reader-service-account"
    }
    labels = {
      "istio/multiCluster" = "true"
    }
    name      = "istio-remote-secret-${data.terraform_remote_state.cluster2.outputs.cluster_name}"
    namespace = "istio-system"
  }
  data = {
    cluster1_name = templatefile("${path.module}/istio-remote-secret.tftpl",
      {
        cluster_certificate_authority_data = data.terraform_remote_state.cluster2.outputs.cluster_certificate_authority_data
        cluster_host                       = data.terraform_remote_state.cluster2.outputs.cluster_endpoint
        cluster_name                       = data.terraform_remote_state.cluster2.outputs.cluster_name
        cluster_istio_reader_token         = data.terraform_remote_state.cluster2.outputs.istio-reader-token
      }
    )
  }
}
################################################################################
# Istio remote secret for cluster 2 (istioctl x create-remote-secret)
################################################################################

resource "kubernetes_secret" "istio_remote_secret_cluster1" {
  provider = kubernetes.cluster2

  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = "istio-reader-service-account"
    }
    labels = {
      "istio/multiCluster" = "true"
    }
    name      = "istio-remote-secret-${data.terraform_remote_state.cluster1.outputs.cluster_name}"
    namespace = "istio-system"
  }
  data = {
    cluster1_name = templatefile("${path.module}/istio-remote-secret.tftpl",
      {
        cluster_certificate_authority_data = data.terraform_remote_state.cluster1.outputs.cluster_certificate_authority_data
        cluster_host                       = data.terraform_remote_state.cluster1.outputs.cluster_endpoint
        cluster_name                       = data.terraform_remote_state.cluster1.outputs.cluster_name
        cluster_istio_reader_token         = data.terraform_remote_state.cluster1.outputs.istio-reader-token
      }
    )
  }
}
