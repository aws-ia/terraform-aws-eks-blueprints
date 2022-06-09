provider "aws" {
  region = local.region
}

data "aws_region" "current" {}

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

locals {
  tenant      = var.tenant      # AWS account name or unique id for tenant
  environment = var.environment # Environment area eg., preprod or prod
  zone        = var.zone        # Environment with in one sub_tenant or business unit
  region      = "us-east-2"

  vpc_cidr     = "10.0.0.0/16"
  vpc_name     = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

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
# Example to consume eks_blueprints module
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../.."

  tenant      = local.tenant
  environment = local.environment
  zone        = local.zone

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  cluster_version = "1.21"

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.large"]
      min_size        = "2"
      subnet_ids      = module.aws_vpc.private_subnets
    }
  }
}

module "eks_blueprints_kubernetes_addons" {
  source         = "../../modules/kubernetes-addons"
  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  #K8s Add-ons
  enable_secrets_store_csi_driver              = true
  enable_secrets_store_csi_driver_provider_aws = true

  depends_on = [module.eks_blueprints.managed_node_groups]
}


data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

#-----------------------------------------------------------------
# This generates a random secret and stores in AWS Secret Manager
#-----------------------------------------------------------------


resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "application_secret" {
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.application_secret.id
  secret_string = <<EOF
   {
    "username": "adminaccount",
    "password": "${random_password.password.result}"
   }
EOF
}

#------------------------------------------------------------------------------------
# This creates a IAM Policy content limiting access to the secret in Secrets Manager
#------------------------------------------------------------------------------------

data "aws_iam_policy_document" "secrets_management_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    resources = [
      aws_secretsmanager_secret_version.sversion.arn
    ]
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
  }
}

#---------------------------------------------------------------
# Creating IAM Policy to be attached to the IRSA Role
#---------------------------------------------------------------

resource "aws_iam_policy" "this" {
  description = "Sample application IAM Policy for IRSA"
  name        = "${module.eks_blueprints.eks_cluster_id}-${var.application}-irsa"
  policy      = data.aws_iam_policy_document.secrets_management_policy.json
}

#---------------------------------------------------------------
# Creating IAM Role for Service Account
#---------------------------------------------------------------

module "iam_role_service_account" {
  source = "../../modules/irsa"
  addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = data.aws_eks_cluster.eks_cluster.endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_cluster_id                 = module.eks_blueprints.eks_cluster_id
    eks_oidc_issuer_url            = module.eks_blueprints.eks_oidc_issuer_url
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks_blueprints.eks_oidc_issuer_url}"
    tags                           = {}
  }
  kubernetes_namespace       = var.application
  kubernetes_service_account = "${var.application}-sa"
  irsa_iam_policies          = [aws_iam_policy.this.arn]

  depends_on = [module.eks_blueprints]
}

#---------------------------------------------------------------
# Kubernetes CRD to create the "SecretProviderClass" to represent the Secrets Manager Secrets
# Refer https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html#integrating_csi_driver_SecretProviderClass for syntax
#---------------------------------------------------------------

resource "kubectl_manifest" "csi_secrets_store_crd" {
  yaml_body = yamlencode({
    apiVersion = "secrets-store.csi.x-k8s.io/v1alpha1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "${var.application}-secrets"
      namespace = var.application
    }
    spec = {
      provider = "aws"
      parameters = {
        objects = <<-EOT
          - objectName : ${aws_secretsmanager_secret_version.sversion.arn}
        EOT
      }
    }
  })
  depends_on = [module.iam_role_service_account]
}

#---------------------------------------------------------------
# Sample Kubernetes Pod to mount the Secrets as CSI Volume
#---------------------------------------------------------------

resource "kubectl_manifest" "sample_nginx" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Pod"
    metadata = {
      name      = "${var.application}-secrets-pod-sample"
      namespace = var.application
    }
    spec = {
      serviceAccountName = "${var.application}-sa"
      volumes = [
        {
          name = "${var.application}-secrets-volume"
          csi = {
            driver   = "secrets-store.csi.k8s.io"
            readOnly = true
            volumeAttributes = {
              secretProviderClass : "${var.application}-secrets"
            }
          }
        }
      ]
      containers = [
        {
          name  = "${var.application}-deployment"
          image = "nginx"
          ports = [
            {
              containerPort = 80
            }
          ]
          volumeMounts = [
            {
              name      = "${var.application}-secrets-volume"
              mountPath = "/mnt/secrets-store"
              readOnly  = true
            }
          ]
        }
      ]
    }
  })
  depends_on = [kubectl_manifest.csi_secrets_store_crd, module.iam_role_service_account]
}
