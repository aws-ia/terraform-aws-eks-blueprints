provider "aws" {
  region  = local.region
  profile = local.hub_profile
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region, "--profile", local.hub_profile]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region, "--profile", local.hub_profile]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region, "--profile", local.hub_profile]
    command     = "aws"
  }
  load_config_file  = false
  apply_retry_count = 15
}

# To get the hosted zone to be use in argocd domain
data "aws_route53_zone" "domain_name" {
  count        = local.enable_ingress ? 1 : 0
  name         = local.domain_name
  private_zone = local.domain_private_zone
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

locals {
  name        = var.hub_cluster_name
  domain_name = var.domain_name

  cluster_version = "1.24"

  instance_type = "m5.large"

  vpc_cidr  = "10.0.0.0/16"
  azs_count = 3
  azs       = slice(data.aws_availability_zones.available.names, 0, local.azs_count)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

  argocd_namespace         = "argocd"
  argocd_namespaces_prefix = var.argocd_namespaces_prefix

  # Ingress Config
  enable_ingress      = var.enable_ingress
  argocd_subdomain    = var.argocd_subdomain
  argocd_domain_arn   = local.enable_ingress ? data.aws_route53_zone.domain_name[0].arn : ""
  domain_private_zone = var.domain_private_zone
  grafana_subdomain   = var.grafana_subdomain

  # Multi-{account,region} setup
  region      = var.hub_region
  hub_profile = var.hub_profile

  # ArgoCD Helm values for base
  argocd_values = templatefile("${path.module}/helm-argocd/values.yaml", {
    irsa_iam_role_arn = module.argocd_irsa.irsa_iam_role_arn
    host              = "${local.argocd_subdomain}.${local.domain_name}"
    enable_ingress    = local.enable_ingress
  })

  # ArgoCD Helm values for AWS Cognito SSO Login
  argocd_sso = var.argocd_enable_sso && local.enable_ingress ? templatefile("${path.module}/helm-argocd/cognito.yaml", {
    issuer       = var.argocd_sso_issuer
    clientID     = var.argocd_sso_client_id
    clientSecret = var.argocd_sso_client_secret
    logoutURL    = "${var.argocd_sso_logout_url}?client_id=${var.argocd_sso_client_id}&logout_uri=https://${local.argocd_subdomain}.${local.domain_name}/logout"
    cliClientID  = var.argocd_sso_cli_client_id
    url          = "https://${local.argocd_subdomain}.${local.domain_name}"
  }) : ""

}

################################################################################
# Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.10"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = [local.instance_type]

      min_size     = 3
      max_size     = 10
      desired_size = 5
    }
  }

  tags = local.tags
}

################################################################################
# Kubernetes Addons
################################################################################

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/csantanapr/terraform-aws-eks-blueprints-addons?ref=argo-multi-cluster" #TODO change git org to aws-ia

  eks_cluster_id       = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_oidc_provider    = module.eks.oidc_provider
  eks_cluster_version  = module.eks.cluster_version

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates addons to be install via ArgoCD
  argocd_helm_config = {
    namespace = local.argocd_namespace
    version   = "5.23.1" # ArgoCD v2.6.2
    values    = [local.argocd_values, local.argocd_sso]
  }

  # Add-ons
  enable_aws_load_balancer_controller = true                                # ArgoCD UI depends on aws-loadbalancer-controller for Ingress
  enable_metrics_server               = true                                # ArgoCD HPAs depend on metric-server
  enable_external_dns                 = local.enable_ingress ? true : false # ArgoCD Server and UI use valid https domain name
  external_dns_helm_config = {
    domainFilters : [local.domain_name]
  }
  external_dns_route53_zone_arns = [local.argocd_domain_arn] # ArgoCD Server and UI domain name is registered in Route 53

  # Observability for ArgoCD
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_prometheus                    = true
  enable_amazon_prometheus             = true

  enable_crossplane = false
  crossplane_helm_config = {
    version = "1.11.1" # Get the latest version from https://charts.crossplane.io/stable
  }
  crossplane_aws_provider = {
    enable               = true
    provider_config      = "aws-provider-config"
    provider_aws_version = "v0.37.1" # Get the latest version from https://marketplace.upbound.io/providers/crossplane-contrib/provider-aws
  }
  crossplane_upbound_aws_provider = {
    enable               = false
    provider_config      = "aws-provider-config"
    provider_aws_version = "v0.30.0" # Get the latest version from   https://marketplace.upbound.io/providers/upbound/provider-aws
  }
  crossplane_kubernetes_provider = {
    enable                      = true
    provider_kubernetes_version = "v0.7.0" # Get the latest version from  https://marketplace.upbound.io/providers/crossplane-contrib/provider-kubernetes
  }
  crossplane_helm_provider = {
    enable                = true
    provider_helm_version = "v0.14.0" # Get the latest version from https://marketplace.upbound.io/providers/crossplane-contrib/provider-helm
  }

  tags = local.tags
}

################################################################################
# EKS Blueprints Add-Ons via ArgoCD
################################################################################

module "eks_blueprints_argocd_addons" {
  source = "github.com/csantanapr/terraform-aws-eks-blueprints-addons//modules/argocd?ref=argo-multi-cluster" #TODO change git org to aws-ia

  argocd_skip_install = true # Skip argocd controller install

  helm_config = {
    namespace        = local.argocd_namespace
    create_namespace = false
  }

  applications = {
    # This shows how to deploy Cluster addons using ArgoCD App of Apps pattern
    addons = {
      add_on_application = true
      path               = "chart"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-add-ons.git"
      target_revision    = "argo-multi-cluster" #TODO change main
      #repo_url             = "git@github.com:csantanapr-test-gitops-1/eks-blueprints-add-ons.git" #TODO change to https://github.com/aws-samples/eks-blueprints-add-ons once git repo is updated
      #ssh_key_secret_name  = "github-ssh-key" # Needed for private repos
      #git_secret_namespace = "argocd"
      #git_secret_name      = "${local.name}-addons"
    }
  }

  addon_config = { for k, v in module.eks_blueprints_kubernetes_addons.argocd_addon_config : k => v if v != null }

  addon_context = {
    aws_region_name                = local.region
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    eks_cluster_id                 = module.eks.cluster_name
  }

  depends_on = [module.eks_blueprints_kubernetes_addons]
}


################################################################################
# EKS Workloads via ArgoCD
################################################################################

module "eks_blueprints_argocd_workloads" {
  source = "github.com/csantanapr/terraform-aws-eks-blueprints-addons//modules/argocd?ref=argo-multi-cluster" #TODO change git org to aws-ia

  argocd_skip_install = true # Skip argocd controller install

  helm_config = {
    namespace        = local.argocd_namespace
    create_namespace = false
  }

  applications = {
    # This shows how to deploy an application to leverage cluster generator  https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Cluster/
    application-set = {
      add_on_application = false
      path               = "application-sets"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-workloads.git"
      target_revision    = "argo-multi-cluster" #TODO change to main
      #repo_url             = "git@github.com:csantanapr-test-gitops-1/eks-blueprints-workloads.git" #TODO change to https://github.com/aws-samples/eks-blueprints-workloads once git repo is updated
      #ssh_key_secret_name  = "github-ssh-key"# Needed for private repos
      #git_secret_namespace = "argocd"
      #git_secret_name      = "${local.name}-workloads"
    }

  }

  addon_context = {
    aws_region_name                = local.region
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    eks_cluster_id                 = module.eks.cluster_name
  }

  depends_on = [module.eks_blueprints_argocd_addons]

}

################################################################################
# ArgoCD EKS Access
################################################################################

module "argocd_irsa" {
  source = "github.com/csantanapr/terraform-aws-eks-blueprints-addons//modules/eks-blueprints-addon?ref=argo-multi-cluster"  #TODO change git org to aws-ia

  create_release = false
  create_role    = true
  role_name      = "${module.eks.cluster_name}-argocd-hub"
  role_policy_arns = {
    ArgoCD_EKS_Policy = aws_iam_policy.irsa_policy.arn
  }
  oidc_providers = {
    this = {
      provider_arn    = module.eks.oidc_provider_arn
      namespace       = local.argocd_namespace
      service_account = "argocd-*"
    }
  }
  tags = local.tags

}

resource "aws_iam_policy" "irsa_policy" {
  name        = "${module.eks.cluster_name}-argocd-irsa"
  description = "IAM Policy for ArgoCD Hub"
  policy      = data.aws_iam_policy_document.irsa_policy.json
  tags        = local.tags
}

data "aws_iam_policy_document" "irsa_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["sts:AssumeRole"]
  }
}

################################################################################
# Grafana
################################################################################

resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  version          = "6.52.1"
  namespace        = "grafana"
  create_namespace = true


  values = [templatefile("${path.module}/helm-grafana/values.yaml", {
    host             = "${local.grafana_subdomain}.${local.domain_name}"
    enable_ingress   = local.enable_ingress
    operating_system = "linux"
  })]

  depends_on = [module.eks_blueprints_kubernetes_addons]
}


################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
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


################################################################################
# ACM Certificate
################################################################################

resource "aws_acm_certificate" "cert" {
  count             = local.enable_ingress ? 1 : 0
  domain_name       = "*.${local.domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert" {
  count           = local.enable_ingress ? 1 : 0
  zone_id         = data.aws_route53_zone.domain_name[0].zone_id
  name            = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_name
  type            = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_type
  records         = [tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_value]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "cert" {
  count                   = local.enable_ingress ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
}
