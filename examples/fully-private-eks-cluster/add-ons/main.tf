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

  # backend "s3" {}

  cloud {
    organization = "skdemo"
    workspaces {
      name = "private-addons-useast1"
    }
  }

}
provider "aws" {
  region = var.region
  alias  = "default"
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

locals {
  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------
  addon_application = {
    path               = "chart"
    repo_url           = "https://github.com/satveerkhurpa/eks-blueprints-add-ons"
    add_on_application = true
  }

  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------
  workload_application = {
    path     = "envs/dev"
    repo_url = "https://github.com/aws-samples/eks-blueprints-workloads.git"
    values = {
      spec = {
        ingress = {
          host = var.eks_cluster_domain
        }
      }
    }
    add_on_application = false
  }
}

module "kubernetes-addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id     = var.eks_cluster_id
  eks_cluster_domain = var.eks_cluster_domain

  #---------------------------------------------------------------
  # ARGO CD ADD-ON
  #---------------------------------------------------------------

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying Add-ons.
  argocd_applications = {
    addons    = local.addon_application
    workloads = local.workload_application
  }

  #---------------------------------------------------------------
  # INGRESS NGINX ADD-ON
  #---------------------------------------------------------------

  enable_ingress_nginx = true
  ingress_nginx_helm_config = {
    values = [templatefile("${path.module}/helm_values/nginx-values.yaml", {
      hostname     = var.eks_cluster_domain
      ssl_cert_arn = data.aws_acm_certificate.issued.arn
    })]
  }

  #---------------------------------------------------------------
  # OTHER ADD-ONS
  #---------------------------------------------------------------

  enable_cert_manager   = true
  enable_metrics_server = true
  enable_vpa            = true
  enable_external_dns   = true
  #enable_aws_load_balancer_controller = false
  enable_cluster_autoscaler           = true


  enable_amazon_eks_aws_ebs_csi_driver = true
  amazon_eks_aws_ebs_csi_driver_config = {
    addon_name               = "aws-ebs-csi-driver"
    addon_version            = "v1.6.0-eksbuild.1"
    service_account          = "ebs-csi-controller-sa"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }

  # Amazon Prometheus Configuration to integrate with Prometheus Server Add-on

  # enable_amazon_prometheus             = true
  # amazon_prometheus_workspace_endpoint = var.amazon_prometheus_workspace_endpoint

  # enable_prometheus = true
  # prometheus_helm_config = {
  #   name       = "prometheus"
  #   repository = "https://prometheus-community.github.io/helm-charts"
  #   chart      = "prometheus"
  #   version    = "15.3.0"
  #   namespace  = "prometheus"
  #   values = [templatefile("${path.module}/helm_values/prometheus-values.yaml", {
  #     operating_system = "linux"
  #   })]
  # }


}

