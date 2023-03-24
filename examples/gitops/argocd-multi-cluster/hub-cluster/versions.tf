terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.18"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    grafana = {
      source = "grafana/grafana"
      version = "1.36.1"
    }
  }
}
