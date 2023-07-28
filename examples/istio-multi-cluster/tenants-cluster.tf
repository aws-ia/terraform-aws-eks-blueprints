
locals {
  tenant-cluster-name  = format("%s-%s", basename(path.cwd), "tenant")
  tenant_istio_network = local.tenant-cluster-name
  tenant_istio_meshID  = local.tenant-cluster-name
  # region = "eu-west-1"

  # vpc_cidr = "10.0.0.0/16"
  # azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # istio_chart_url     = "https://istio-release.storage.googleapis.com/charts"
  # istio_chart_version = "1.18.1"

  # tags = {
  #   Blueprint  = local.name
  #   GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  # }
}

provider "kubernetes" {
  host                   = module.tenant_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.tenant_cluster.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.tenant_cluster.cluster_name]
  }
  alias = "tenant_cluster"
}

provider "helm" {
  kubernetes {
    host                   = module.tenant_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.tenant_cluster.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.tenant_cluster.cluster_name]
    }
  }
  alias = "tenant_cluster"
}

################################################################################
# Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "tenant_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name                   = local.tenant-cluster-name
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true

  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 5
      desired_size = 2
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

module "eks_blueprints_addons_tenant" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.tenant_cluster.cluster_name
  cluster_endpoint  = module.tenant_cluster.cluster_endpoint
  cluster_version   = module.tenant_cluster.cluster_version
  oidc_provider_arn = module.tenant_cluster.oidc_provider_arn

  # This is required to expose Istio Ingress Gateway
  enable_aws_load_balancer_controller = true

  tags = local.tags
}

################################################################################
# Istio
################################################################################

resource "kubernetes_namespace" "istio_system_tenant" {
  provider = kubernetes.tenant_cluster
  metadata {
    name = "istio-system"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "helm_release" "istio_base_tenant" {
  provider   = helm.tenant_cluster
  repository = local.istio_chart_url
  chart      = "base"
  name       = "istio-base"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = local.istio_chart_version
  wait       = false

  depends_on = [
    module.eks_blueprints_addons_tenant
  ]
}

resource "helm_release" "istiod_tenant" {
  provider   = helm.tenant_cluster
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

  # set {
  #   name = "global.proxyMetadata"
  #   value = {
  #     ISTIO_META_DNS_CAPTURE : "true"
  #   ISTIO_META_DNS_AUTO_ALLOCATE : "true" }
  # }

  set {
    name  = "global.multiCluster.clusterName"
    value = local.tenant-cluster-name
  }

  set {
    name  = "global.meshID"
    value = local.tenant_istio_meshID
  }

  set {
    name  = "global.network"
    value = local.tenant_istio_network
  }
}

resource "helm_release" "istio_ingress_tenant" {
  provider   = helm.tenant_cluster
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

