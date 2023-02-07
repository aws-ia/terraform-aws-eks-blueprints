provider "aws" {
  region = local.region
}

provider "bcrypt" {
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
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

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

  namespace = "argocd"
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../../../../"

  cluster_name    = local.name
  cluster_version = "1.24"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.small"]
      min_size        = 1
      max_size        = 4
      desired_size    = 3
      subnet_ids      = module.vpc.private_subnets
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# EKS Blueprints Add-Ons
#---------------------------------------------------------------
module "eks_blueprints_kubernetes_addons" {
  source = "../../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  enable_argocd         = true
  argocd_manage_add_ons = true
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
    hub-cluster-addons = {
      path               = "chart"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-add-ons.git"
      target_revision    = "argo-multi-cluster"
      add_on_application = true
    }
  }

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
  eks_cluster_id                    = module.eks_blueprints.eks_cluster_id
  eks_oidc_provider_arn             = module.eks_blueprints.eks_oidc_provider_arn
  tags                              = local.tags
}

resource "aws_iam_policy" "irsa_policy" {
  name        = "${module.eks_blueprints.eks_cluster_id}-argocd-irsa"
  description = "IAM Policy for ArgoCD Hub"
  policy      = data.aws_iam_policy_document.irsa_policy.json
  tags        = local.tags
}
