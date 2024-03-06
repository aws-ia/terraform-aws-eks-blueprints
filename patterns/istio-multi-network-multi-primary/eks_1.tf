provider "kubernetes" {
  host                   = module.eks_1.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_1.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_1.cluster_name]
  }
  alias = "kubernetes_1"
}

provider "helm" {
  kubernetes {
    host                   = module.eks_1.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_1.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_1.cluster_name]
    }
  }
  alias = "helm_1"
}

################################################################################
# VPC
################################################################################

module "vpc_1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.eks_1_name}-vpc"
  cidr = local.vpc_1_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_1_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_1_cidr, 8, k + 48)]

  enable_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = merge({
    Name = "${local.eks_1_name}-vpc"
  }, local.tags)
}

################################################################################
# Cluster
################################################################################

module "eks_1" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name                   = local.eks_1_name
  cluster_version                = local.eks_cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      preserve = true
    }
  }

  vpc_id     = module.vpc_1.vpc_id
  subnet_ids = module.vpc_1.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.medium"]

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

resource "kubernetes_namespace_v1" "istio_system_1" {
  metadata {
    name = "istio-system"
    labels = {
      "topology.istio.io/network" = local.networkName1
    }
  }
  provider = kubernetes.kubernetes_1
}

resource "kubernetes_namespace_v1" "istio_ingress_1" {
  metadata {
    name = "istio-ingress"
  }
  provider = kubernetes.kubernetes_1
}

# Create secret for custom certificates in Cluster 1
resource "kubernetes_secret" "cacerts_cluster1" {
  metadata {
    name      = "cacerts"
    namespace = kubernetes_namespace_v1.istio_system_1.metadata[0].name
  }

  data = {
    "ca-cert.pem"    = tls_locally_signed_cert.intermediate_ca_cert_1.cert_pem
    "ca-key.pem"     = tls_private_key.intermediate_ca_key_1.private_key_pem
    "root-cert.pem"  = tls_self_signed_cert.root_ca.cert_pem
    "cert-chain.pem" = format("%s\n%s",tls_locally_signed_cert.intermediate_ca_cert_1.cert_pem, tls_self_signed_cert.root_ca.cert_pem)
  }

  provider = kubernetes.kubernetes_1
}

resource "tls_private_key" "intermediate_ca_key_1" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "intermediate_ca_csr_1" {
  private_key_pem = tls_private_key.intermediate_ca_key_1.private_key_pem

  subject {
    common_name  = "intermediate.multicluster.istio.io"
  }
}

resource "tls_locally_signed_cert" "intermediate_ca_cert_1" {
  cert_request_pem = tls_cert_request.intermediate_ca_csr_1.cert_request_pem
  ca_private_key_pem = tls_private_key.root_ca_key.private_key_pem
  ca_cert_pem = tls_self_signed_cert.root_ca.cert_pem

  validity_period_hours = 87600
  is_ca_certificate     = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "cert_signing",
  ]
}

module "eks_1_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks_1.cluster_name
  cluster_endpoint  = module.eks_1.cluster_endpoint
  cluster_version   = module.eks_1.cluster_version
  oidc_provider_arn = module.eks_1.oidc_provider_arn

  # This is required to expose Istio Ingress Gateway
  enable_aws_load_balancer_controller = true

  helm_releases = {
    istio-base = {
      chart         = "base"
      chart_version = local.istio_chart_version
      repository    = local.istio_chart_url
      name          = "istio-base"
      namespace     = kubernetes_namespace_v1.istio_system_1.metadata[0].name
    }

    istiod = {
      chart         = "istiod"
      chart_version = local.istio_chart_version
      repository    = local.istio_chart_url
      name          = "istiod"
      namespace     = kubernetes_namespace_v1.istio_system_1.metadata[0].name

      set = [
        {
          name  = "meshConfig.accessLogFile"
          value = "/dev/stdout"
        },
        {
          name  = "global.meshID"
          value = local.meshID
        },
        {
          name  = "global.multiCluster.clusterName"
          value = local.clusterName1
        },
        {
          name  = "global.network"
          value = local.networkName1
        },
        {
          name  = "gateways.istio-ingressgateway.injectionTemplate"
          value = "gateway"
        }
      ]
    }

    istio-ingress = {
      chart         = "gateway"
      chart_version = local.istio_chart_version
      repository    = local.istio_chart_url
      name          = "istio-ingressgateway"
      namespace     = kubernetes_namespace_v1.istio_ingress_1.metadata[0].name # per https://github.com/istio/istio/blob/master/manifests/charts/gateways/istio-ingress/values.yaml#L2
      values = [
        yamlencode(
          {
            labels = {
              istio = "ingressgateway"
            }
            service = {
              annotations = {
                "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
                "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
                "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
                "service.beta.kubernetes.io/aws-load-balancer-attributes"      = "load_balancing.cross_zone.enabled=true"
              }
              ports = [
                {
                  name       = "tls-istiod"
                  port       = 15012
                  targetPort = 15012
                },
                {
                  name       = "tls-webhook"
                  port       = 15017
                  targetPort = 15017
                }
              ]
            }
          }
        )
      ]
    }

    istio-eastwestgateway = {
      chart         = "gateway"
      chart_version = local.istio_chart_version
      repository    = local.istio_chart_url
      name          = "istio-eastwestgateway"
      namespace     = kubernetes_namespace_v1.istio_ingress_1.metadata[0].name # per https://github.com/istio/istio/blob/master/manifests/charts/gateways/istio-ingress/values.yaml#L2

      values = [
        yamlencode(
          {
            labels = {
              istio                       = "eastwestgateway"
              app                         = "istio-eastwestgateway"
              "topology.istio.io/network" = local.networkName1
            }
            env = {
              "ISTIO_META_REQUESTED_NETWORK_VIEW" = local.networkName1
            }
            service = {
              annotations = {
                "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
                "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
                "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
                "service.beta.kubernetes.io/aws-load-balancer-attributes"      = "load_balancing.cross_zone.enabled=true"
              }
              ports = [
                {
                  name       = "tls"
                  port       = 15443
                  targetPort = 15443
                }
              ]
            }
          }
        )
      ]
    }
  }

  tags = local.tags

  providers = {
    kubernetes = kubernetes.kubernetes_1
    helm       = helm.helm_1
  }
}

resource "kubernetes_secret" "istio_reader_token_1" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = "istio-reader-service-account"
    }
    name      = "istio-reader-service-account-istio-remote-secret-token"
    namespace = module.eks_1_addons.helm_releases.istiod.namespace
  }
  type = "kubernetes.io/service-account-token"

  provider = kubernetes.kubernetes_1
}

data "kubernetes_secret" "istio_reader_token_1" {
  metadata {
    name      = kubernetes_secret.istio_reader_token_1.metadata[0].name
    namespace = module.eks_1_addons.helm_releases.istiod.namespace
  }
  provider = kubernetes.kubernetes_1
}

resource "kubernetes_namespace_v1" "sample_namespace_1" {
  metadata {
    name = "sample"
    labels = {
      "istio-injection" = "enabled"
    }
  }
  provider = kubernetes.kubernetes_1
}

resource "helm_release" "multicluster_gateway_n_apps_1" {
  name       = "multicluster-gateway-n-apps"
  repository = "charts"
  namespace  = kubernetes_namespace_v1.sample_namespace_1.metadata[0].name
  chart      = "multicluster-gateway-n-apps"

  set {
    name  = "version"
    value = "v1"
  }

  set {
    name  = "clusterName"
    value = local.clusterName2
  }

  set {
    name  = "certificateAuthorityData"
    value = module.eks_2.cluster_certificate_authority_data
  }

  set {
    name  = "server"
    value = module.eks_2.cluster_endpoint
  }

  set {
    name  = "token"
    value = kubernetes_secret.istio_reader_token_2.data["token"]
  }

  provider = helm.helm_1
}