provider "aws" {
  region = local.region
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

provider "bcrypt" {}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = local.name
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

      min_size     = 3
      max_size     = 10
      desired_size = 5
    }
  }

  tags = merge(local.tags, {
    git_commit           = "19c7cfd40c4b83ec534b3ffcd70c3a3efc42ffd1"
    git_file             = "examples/argocd/main.tf"
    git_last_modified_at = "2023-06-05 14:07:47"
    git_last_modified_by = "kuapoorv@amazon.com"
    git_modifiers        = "bryantbiggs/kuapoorv"
    git_org              = "cpieper78"
    git_repo             = "terraform-aws-eks-blueprints"
    yor_name             = "eks"
    yor_trace            = "95cb7d9f-5f1c-4699-8cb5-f0ade75f5869"
  })
}

################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  # Users should pin the version to the latest available release
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"

  eks_cluster_id        = module.eks.cluster_name
  eks_cluster_endpoint  = module.eks.cluster_endpoint
  eks_cluster_version   = module.eks.cluster_version
  eks_oidc_provider     = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn

  enable_argocd = true
  # This example shows how to set default ArgoCD Admin Password using SecretsManager with Helm Chart set_sensitive values.
  argocd_helm_config = {
    set_sensitive = [
      {
        name  = "configs.secret.argocdServerAdminPassword"
        value = bcrypt_hash.argo.id
      }
    ]
  }

  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying add-ons
  argocd_applications = {
    addons = {
      path               = "chart"
      repo_url           = "https://github.com/aws-samples/eks-blueprints-add-ons.git"
      add_on_application = true
    }
    workloads = {
      path               = "envs/dev"
      repo_url           = "https://github.com/aws-samples/eks-blueprints-workloads.git"
      add_on_application = false
    }
  }

  # Add-ons
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_load_balancer_controller  = true
  enable_cert_manager                  = true
  enable_karpenter                     = true
  enable_metrics_server                = true
  enable_argo_rollouts                 = true

  tags = merge(local.tags, {
    git_commit           = "0cb73da0305b078c64575d559f29281bda8f1e3e"
    git_file             = "examples/argocd/main.tf"
    git_last_modified_at = "2023-06-07 00:10:11"
    git_last_modified_by = "bryantbiggs@gmail.com"
    git_modifiers        = "bryantbiggs/kuapoorv"
    git_org              = "cpieper78"
    git_repo             = "terraform-aws-eks-blueprints"
    yor_name             = "eks_blueprints_addons"
    yor_trace            = "d4d0f52e-173c-4cf3-99a5-66ff50715477"
  })
}

#---------------------------------------------------------------
# ArgoCD Admin Password credentials with Secrets Manager
# Login to AWS Secrets manager with the same role as Terraform to extract the ArgoCD admin password with the secret name as "argocd"
#---------------------------------------------------------------
resource "random_password" "argocd" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Argo requires the password to be bcrypt, we use custom provider of bcrypt,
# as the default bcrypt function generates diff for each terraform plan
resource "bcrypt_hash" "argo" {
  cleartext = random_password.argocd.result
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "argocd" {
  name                    = "argocd"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
  tags = {
    git_commit           = "243ae23284c132753957508de3f724c0af73ebf0"
    git_file             = "examples/argocd/main.tf"
    git_last_modified_at = "2023-02-14 21:25:25"
    git_last_modified_by = "bryantbiggs@gmail.com"
    git_modifiers        = "bryantbiggs"
    git_org              = "cpieper78"
    git_repo             = "terraform-aws-eks-blueprints"
    yor_name             = "argocd"
    yor_trace            = "51058cf1-2e9b-4430-88ff-38219342dd32"
  }
}

resource "aws_secretsmanager_secret_version" "argocd" {
  secret_id     = aws_secretsmanager_secret.argocd.id
  secret_string = random_password.argocd.result
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = merge(local.tags, {
    git_commit           = "19c7cfd40c4b83ec534b3ffcd70c3a3efc42ffd1"
    git_file             = "examples/argocd/main.tf"
    git_last_modified_at = "2023-06-05 14:07:47"
    git_last_modified_by = "kuapoorv@amazon.com"
    git_modifiers        = "bryantbiggs/kuapoorv"
    git_org              = "cpieper78"
    git_repo             = "terraform-aws-eks-blueprints"
    yor_name             = "vpc"
    yor_trace            = "091cdba5-4333-4c14-92d2-e1dc83156570"
  })
}
