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
  tenant          = var.tenant      # AWS account name or unique id for tenant
  environment     = var.environment # Environment area eg., preprod or prod
  zone            = var.zone        # Environment with in one sub_tenant or business unit
  cluster_version = var.cluster_version

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

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  #K8s Add-ons
  enable_csi_secrets_store_provider_aws = true
  # csi_secrets_store_provider_aws_secrets_config = templatefile("${path.module}/secretconfig.yaml", {})

  depends_on = [module.eks-blueprints.managed_node_groups]
}


data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = module.eks-blueprints.eks_cluster_id
}

#---------------------------------------------------------------
# Parsing the config file to local and also extracting the ARNs of Secret Object
#---------------------------------------------------------------
locals {
 secretconfig = templatefile("${path.module}/secretconfig.yaml", {})
 all_secret_arn = [for alarms in yamldecode(local.secretconfig): alarms["objectName"] ]
}

#---------------------------------------------------------------
# Creating IAM Policy to be attached to the IRSA Role
#---------------------------------------------------------------

resource "aws_iam_policy" "this" {
  description = "Sample application IAM Policy for IRSA"
  name        = "${module.eks-blueprints.eks_cluster_id}-${var.application}-irsa"
  policy      = data.aws_iam_policy_document.secrets_management_policy.json
}

#---------------------------------------------------------------
# Creating IAM Role for Service Account
#---------------------------------------------------------------

module "iam_role_service_account" {
  source                = "../../modules/irsa"
  addon_context         = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = data.aws_eks_cluster.eks_cluster.endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_cluster_id                 = module.eks-blueprints.eks_cluster_id
    eks_oidc_issuer_url            = module.eks-blueprints.eks_oidc_issuer_url
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks-blueprints.eks_oidc_issuer_url}"
    tags                           = {}
  }
  kubernetes_namespace  = var.application
  kubernetes_service_account  = "${var.application}-sa"
  irsa_iam_policies = [aws_iam_policy.this.arn]

  depends_on = [module.eks-blueprints]
}

#---------------------------------------------------------------
# Kubernetes CRD to create the "SecretProviderClass" to represent the Secrets Manager Secrets
#---------------------------------------------------------------

resource "kubernetes_manifest" "csi_secrets_store_crd" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1alpha1"
    kind  = "SecretProviderClass"
    metadata  = {
      name = "${var.application}-secrets"
      namespace = var.application
    }
    spec = {
      provider: "aws"
      parameters = {
        objects = local.secretconfig
      }
    }
  }
  depends_on = [module.iam_role_service_account]
}

#---------------------------------------------------------------
# Sample Kubernetes Pod to mount the Secrets as CSI Volume
#---------------------------------------------------------------

resource "kubernetes_manifest" "sample_nginx" {
  manifest = {
    apiVersion = "v1"
    kind  = "Pod"
    metadata  = {
      name = "${var.application}-secrets-pod-sample"
      namespace = var.application
    }
    spec = {
      serviceAccountName = "${var.application}-sa"
      volumes = [
        {
          name = "${var.application}-secrets-volume"
          csi = {
            driver = "secrets-store.csi.k8s.io"
            readOnly = true
            volumeAttributes = {
              secretProviderClass: "${var.application}-secrets"
            }
          }
        }
      ]
      containers = [
        {
          name = "${var.application}-deployment"
          image = "nginx"
          ports = [
            {
              containerPort = 80
            }
          ]
          volumeMounts = [
            {
              name = "${var.application}-secrets-volume"
              mountPath = "/mnt/secrets-store"
              readOnly = true
            }
          ]
        }
      ]
    }
  }
  depends_on = [kubernetes_manifest.csi_secrets_store_crd,module.iam_role_service_account]
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks-blueprints.configure_kubectl
}
