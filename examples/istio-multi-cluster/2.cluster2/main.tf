provider "aws" {
  region = local.region
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../0.vpc/terraform.tfstate"
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
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

data "aws_availability_zones" "available" {}

locals {
  cluster_name = var.name
  region       = var.region

  cluster1_additional_sg_id = data.terraform_remote_state.vpc.outputs.cluster1_additional_sg_id
  cluster2_additional_sg_id = data.terraform_remote_state.vpc.outputs.cluster2_additional_sg_id


  istio_chart_url     = "https://istio-release.storage.googleapis.com/charts"
  istio_chart_version = "1.18.2"

  tags = {
    Blueprint  = local.cluster_name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name                   = local.cluster_name
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true

  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.subnet_ids

  eks_managed_node_groups = {
    cluster2 = {
      instance_types = ["m5.large"]

      min_size               = 1
      max_size               = 5
      desired_size           = 2
      vpc_security_group_ids = [local.cluster2_additional_sg_id]

    }
  }
  # SG Rule for nodes in cluster 2 to be able to reach to the cluster1 control plane
  cluster_security_group_additional_rules = {
    ingress_allow_from_other_cluster = {
      description              = "Access EKS from EC2 instances in other cluster."
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = local.cluster1_additional_sg_id
    }
  }

  #  EKS K8s API cluster needs to be able to talk with the EKS worker nodes with port 15017/TCP and 15012/TCP which is used by Istio
  #  Istio in order to create sidecar needs to be able to communicate with webhook and for that network passage to EKS is needed.
  node_security_group_additional_rules = {
    ingress_15017 = {
      description                   = "Cluster API - Istio Webhook namespace.sidecar-injector.istio.io"
      protocol                      = "TCP"
      from_port                     = 15017
      to_port                       = 15017
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_15012 = {
      description                   = "Cluster API to nodes ports/protocols"
      protocol                      = "TCP"
      from_port                     = 15012
      to_port                       = 15012
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  tags = local.tags
}

################################################################################
# EKS Blueprints Addons
################################################################################

module "addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # This is required to expose Istio Ingress Gateway
  enable_aws_load_balancer_controller = true
  enable_cert_manager                 = true

  tags = local.tags
}

################################################################################
# Istio
################################################################################

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "helm_release" "istio_base" {

  repository = local.istio_chart_url
  chart      = "base"
  name       = "istio-base"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = local.istio_chart_version
  wait       = false

  depends_on = [
    module.addons
  ]
}

resource "helm_release" "istiod" {
  repository = local.istio_chart_url
  chart      = "istiod"
  name       = "istiod"
  namespace  = helm_release.istio_base.metadata[0].namespace
  version    = local.istio_chart_version
  wait       = false

  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }

  set {
    name  = "global.multiCluster.clusterName"
    value = local.cluster_name
  }

  set {
    name  = "global.meshID"
    value = local.cluster_name
  }

  set {
    name  = "global.network"
    value = local.cluster_name
  }
}

resource "helm_release" "istio_ingress" {
  repository = local.istio_chart_url
  chart      = "gateway"
  name       = "istio-ingress"
  namespace  = helm_release.istiod.metadata[0].namespace
  version    = local.istio_chart_version
  wait       = false

  values = [
    yamlencode(
      {
        labels = {
          istio = "ingressgateway"
        }
        service = {
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }
      }
    )
  ]
}

################################################################################
# Isito certs for cross-cluster traffice
# https://istio.io/latest/docs/ops/deployment/deployment-models/#trust-within-a-mesh
# https://istio.io/latest/docs/ops/diagnostic-tools/multicluster/#trust-configuration
################################################################################
resource "kubernetes_secret" "cacerts" {
  metadata {
    name      = "cacerts"
    namespace = "istio-system"
  }

  data = {
    "ca-cert.pem"    = "${file("${path.module}/../certs-tool/certs/${local.cluster_name}/ca-cert.pem")}"
    "ca-key.pem"     = "${file("${path.module}/../certs-tool/certs/${local.cluster_name}/ca-key.pem")}"
    "root-cert.pem"  = "${file("${path.module}/../certs-tool/certs/${local.cluster_name}/root-cert.pem")}"
    "cert-chain.pem" = "${file("${path.module}/../certs-tool/certs/${local.cluster_name}/cert-chain.pem")}"
  }
}

################################################################################
# Data source for Istio reader token
################################################################################

resource "kubernetes_secret" "istio_reader" {
  depends_on = [module.addons, helm_release.istiod]
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = "istio-reader-service-account"
    }
    name      = "istio-reader-service-account-istio-remote-secret-token"
    namespace = "istio-system"
  }

  type = "kubernetes.io/service-account-token"
}

data "kubernetes_secret" "istio_reader_data" {
  depends_on = [kubernetes_secret.istio_reader]
  metadata {
    name      = "istio-reader-service-account-istio-remote-secret-token"
    namespace = "istio-system"
  }
}

