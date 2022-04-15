terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }

  backend "local" {
    path = "local_tf_state/terraform-main.tfstate"
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks-blueprints.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-blueprints.eks_cluster_id
}

provider "aws" {
  region = data.aws_region.current.id
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
  tenant            = var.tenant      # AWS account name or unique id for tenant
  environment       = var.environment # Environment area eg., preprod or prod
  zone              = var.zone        # Environment with in one sub_tenant or business unit
  cluster_version   = var.cluster_version
  certificate_name  = var.certificate_name
  certificate_dns   = var.certificate_dns

  vpc_cidr     = "10.0.0.0/16"
  vpc_name     = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.0.1"
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.2.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
#---------------------------------------------------------------
# Example to consume eks-blueprints module
#---------------------------------------------------------------
module "eks-blueprints" {
  source = "../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  cluster_version = local.cluster_version

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m4.large"]
      min_size        = "2"
      subnet_ids      = module.aws_vpc.private_subnets
    }
  }
}

module "eks-blueprints-kubernetes-addons" {
  source         = "../../modules/kubernetes-addons"
  eks_cluster_id = module.eks-blueprints.eks_cluster_id
  aws_privateca_acmca_arn = aws_acmpca_certificate_authority.example.arn

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  #K8s Add-ons
  enable_cert_manager                 = true
  enable_aws_privateca_issuer         = true

  depends_on = [module.eks-blueprints.managed_node_groups]
}


#-------------------------------
#  This resource creates a AWS Certificate Manager Private Certificate Authority (ACM PCA)
#-------------------------------

resource "aws_acmpca_certificate_authority_certificate" "example" {
  certificate_authority_arn = aws_acmpca_certificate_authority.example.arn

  certificate       = aws_acmpca_certificate.example.certificate
  certificate_chain = aws_acmpca_certificate.example.certificate_chain
}

#-------------------------------
#  This resource sends the signing request to ACM PCA, so that it becomes active
#-------------------------------

resource "aws_acmpca_certificate" "example" {
  certificate_authority_arn   = aws_acmpca_certificate_authority.example.arn
  certificate_signing_request = aws_acmpca_certificate_authority.example.certificate_signing_request
  signing_algorithm           = "SHA512WITHRSA"

  template_arn = "arn:${data.aws_partition.current.partition}:acm-pca:::template/RootCACertificate/V1"

  validity {
    type  = "YEARS"
    value = 10
  }
}

#-------------------------------
# Associates a certificate with an AWS Certificate Manager Private Certificate Authority (ACM PCA Certificate Authority). 
# An ACM PCA Certificate Authority is unable to issue certificates until it has a certificate associated with it. 
# A root level ACM PCA Certificate Authority is able to self-sign its own root certificate.
#-------------------------------

resource "aws_acmpca_certificate_authority" "example" {
  type = "ROOT"

  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = "example.com"
    }
  }
}

data "aws_partition" "current" {}


#-------------------------------
#  This resource creates a CRD of AWSPCAClusterIssuer Kind, which then represents the ACM PCA in K8
#-------------------------------

resource "kubernetes_manifest" "cluster-pca-issuer" {
  manifest = {
    apiVersion = "awspca.cert-manager.io/v1beta1"
    kind       = "AWSPCAClusterIssuer"

    metadata = {
      name = module.eks-blueprints.eks_cluster_id
    }

    spec = {
      arn = aws_acmpca_certificate_authority.example.arn
      region: data.aws_region.current.id
    }
  }
  depends_on = [module.eks-blueprints-kubernetes-addons]
}

#-------------------------------
# This resource creates a CRD of Certificate Kind, which then represents certificate issued from ACM PCA,
# mounted as K8 secret
#-------------------------------

resource "kubernetes_manifest" "example_pca_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name = local.certificate_name
      namespace = "default"
    }

    spec = {
      commonName = local.certificate_dns
      duration = "2160h0m0s"
      issuerRef = {
          group = "awspca.cert-manager.io"
          kind = "AWSPCAClusterIssuer"
          name: module.eks-blueprints.eks_cluster_id
      }
      renewBefore = "360h0m0s"
      secretName = join("-", [local.certificate_name, "clusterissuer"]) # This is the name with which the K8 Secret will be available
      usages = [
          "server auth",
          "client auth"
      ]
      privateKey = {
          algorithm: "RSA"
          size: 2048
        }
    }
  }

  depends_on = [module.eks-blueprints-kubernetes-addons, kubernetes_manifest.cluster-pca-issuer]
}



output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks-blueprints.configure_kubectl
}