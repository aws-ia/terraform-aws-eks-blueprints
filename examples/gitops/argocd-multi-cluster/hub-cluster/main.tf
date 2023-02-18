provider "aws" {
  region = local.region
}

provider "bcrypt" {
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region]
      command     = "aws"
    }
  }
}


data "aws_availability_zones" "available" {}

data "aws_iam_policy_document" "irsa_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = ["sts:AssumeRole"]
  }
}

locals {
  name   = "hub-cluster"
  region = "us-west-2"

  cluster_version = "1.24"

  instance_type = "t3.small" #TODO change to m5.large before merging PR

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

  namespace = "argocd"
}


#---------------------------------------------------------------
# EKS Cluster
#---------------------------------------------------------------
#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.7"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = [local.instance_type]

      min_size     = 1
      max_size     = 4
      desired_size = 2
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# EKS Blueprints Add-Ons
#---------------------------------------------------------------
module "eks_blueprints_kubernetes_addons" {
  source = "../../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_oidc_provider    = module.eks.oidc_provider
  eks_cluster_version  = module.eks.cluster_version

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates addons to be install via ArgoCD
  argocd_helm_config = {
    namespace = local.namespace
    version   = "5.19.12"
    values = [
      yamlencode(
        {
          server : {
            serviceAccount : {
              annotations : {
                "eks.amazonaws.com/role-arn" : module.argocd_irsa.irsa_iam_role_arn
              }
            }
            service : {
              type : "LoadBalancer"
            }
          }
          controller : {
            serviceAccount : {
              annotations : {
                "eks.amazonaws.com/role-arn" : module.argocd_irsa.irsa_iam_role_arn
              }
            }
          }
          configs : {
            params : {
              "application.namespaces" : "cluster-*" # See more config options at https://argo-cd.readthedocs.io/en/stable/operator-manual/app-any-namespace/
            }
          }
        }
      )
    ]
    set_sensitive = [
      {
        name  = "configs.secret.argocdServerAdminPassword"
        value = bcrypt_hash.argo.id
      }
    ]
  }

  argocd_applications = {
    addons = {
      path               = "chart"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-add-ons.git"
      target_revision    = "argo-multi-cluster"
      add_on_application = true
    }
  }


  # Add-ons
  enable_ingress_nginx                = false
  enable_aws_load_balancer_controller = true
  enable_datadog_operator             = false
  enable_metrics_server               = true

  tags = local.tags
}

resource "random_password" "argocd" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# argo expects bcrypt
resource "bcrypt_hash" "argo" {
  cleartext = random_password.argocd.result
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "argocd" {
  name = "argocd-login-2"
  # Set to zero for this example to force delete during Terraform destroy
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "argocd" {
  secret_id     = aws_secretsmanager_secret.argocd.id
  secret_string = random_password.argocd.result
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # manage so we can name them
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

module "argocd_irsa" {
  source                            = "../../../../modules/irsa"
  kubernetes_namespace              = local.namespace
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_service_account        = "argocd-*"
  irsa_iam_role_name                = "argocd-hub"
  irsa_iam_policies                 = [aws_iam_policy.irsa_policy.arn]
  eks_cluster_id                    = module.eks.cluster_name
  eks_oidc_provider_arn             = module.eks.oidc_provider_arn
  tags                              = local.tags
}

resource "aws_iam_policy" "irsa_policy" {
  name        = "${module.eks.cluster_name}-argocd-irsa"
  description = "IAM Policy for ArgoCD Hub"
  policy      = data.aws_iam_policy_document.irsa_policy.json
  tags        = local.tags
}
