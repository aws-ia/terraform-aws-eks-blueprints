provider "aws" {
  region = local.region
}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
  }
}

locals {
  name        = "hub-spoke-${local.environment}"
  environment = "control-plane"
  region      = var.region

  cluster_version = var.kubernetes_version

  vpc_cidr = var.vpc_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  gitops_addons_url      = "${var.gitops_addons_org}/${var.gitops_addons_repo}"
  gitops_addons_basepath = var.gitops_addons_basepath
  gitops_addons_path     = var.gitops_addons_path
  gitops_addons_revision = var.gitops_addons_revision

  argocd_namespace = "argocd"

  aws_addons = {
    enable_cert_manager                          = try(var.addons.enable_cert_manager, false)
    enable_aws_efs_csi_driver                    = try(var.addons.enable_aws_efs_csi_driver, false)
    enable_aws_fsx_csi_driver                    = try(var.addons.enable_aws_fsx_csi_driver, false)
    enable_aws_cloudwatch_metrics                = try(var.addons.enable_aws_cloudwatch_metrics, false)
    enable_aws_privateca_issuer                  = try(var.addons.enable_aws_privateca_issuer, false)
    enable_cluster_autoscaler                    = try(var.addons.enable_cluster_autoscaler, false)
    enable_external_dns                          = try(var.addons.enable_external_dns, false)
    enable_external_secrets                      = try(var.addons.enable_external_secrets, false)
    enable_aws_load_balancer_controller          = try(var.addons.enable_aws_load_balancer_controller, false)
    enable_fargate_fluentbit                     = try(var.addons.enable_fargate_fluentbit, false)
    enable_aws_for_fluentbit                     = try(var.addons.enable_aws_for_fluentbit, false)
    enable_aws_node_termination_handler          = try(var.addons.enable_aws_node_termination_handler, false)
    enable_karpenter                             = try(var.addons.enable_karpenter, false)
    enable_velero                                = try(var.addons.enable_velero, false)
    enable_aws_gateway_api_controller            = try(var.addons.enable_aws_gateway_api_controller, false)
    enable_aws_ebs_csi_resources                 = try(var.addons.enable_aws_ebs_csi_resources, false)
    enable_aws_secrets_store_csi_driver_provider = try(var.addons.enable_aws_secrets_store_csi_driver_provider, false)
    enable_ack_apigatewayv2                      = try(var.addons.enable_ack_apigatewayv2, false)
    enable_ack_dynamodb                          = try(var.addons.enable_ack_dynamodb, false)
    enable_ack_s3                                = try(var.addons.enable_ack_s3, false)
    enable_ack_rds                               = try(var.addons.enable_ack_rds, false)
    enable_ack_prometheusservice                 = try(var.addons.enable_ack_prometheusservice, false)
    enable_ack_emrcontainers                     = try(var.addons.enable_ack_emrcontainers, false)
    enable_ack_sfn                               = try(var.addons.enable_ack_sfn, false)
    enable_ack_eventbridge                       = try(var.addons.enable_ack_eventbridge, false)
    enable_aws_argocd                            = try(var.addons.enable_aws_argocd, false)
  }
  oss_addons = {
    enable_argocd                          = try(var.addons.enable_argocd, false)
    enable_argo_rollouts                   = try(var.addons.enable_argo_rollouts, false)
    enable_argo_events                     = try(var.addons.enable_argo_events, false)
    enable_argo_workflows                  = try(var.addons.enable_argo_workflows, false)
    enable_cluster_proportional_autoscaler = try(var.addons.enable_cluster_proportional_autoscaler, false)
    enable_gatekeeper                      = try(var.addons.enable_gatekeeper, false)
    enable_gpu_operator                    = try(var.addons.enable_gpu_operator, false)
    enable_ingress_nginx                   = try(var.addons.enable_ingress_nginx, false)
    enable_kyverno                         = try(var.addons.enable_kyverno, false)
    enable_kube_prometheus_stack           = try(var.addons.enable_kube_prometheus_stack, false)
    enable_metrics_server                  = try(var.addons.enable_metrics_server, false)
    enable_prometheus_adapter              = try(var.addons.enable_prometheus_adapter, false)
    enable_secrets_store_csi_driver        = try(var.addons.enable_secrets_store_csi_driver, false)
    enable_vpa                             = try(var.addons.enable_vpa, false)
  }
  addons = merge(
    local.aws_addons,
    local.oss_addons,
    { kubernetes_version = local.cluster_version },
    { aws_cluster_name = module.eks.cluster_name }
  )

  addons_metadata = merge(
    module.eks_blueprints_addons.gitops_metadata,
    {
      aws_cluster_name = module.eks.cluster_name
      aws_region       = local.region
      aws_account_id   = data.aws_caller_identity.current.account_id
      aws_vpc_id       = module.vpc.vpc_id
    },
    {
      argocd_iam_role_arn = module.argocd_irsa.iam_role_arn
      argocd_namespace    = local.argocd_namespace
    },
    {
      addons_repo_url      = local.gitops_addons_url
      addons_repo_basepath = local.gitops_addons_basepath
      addons_repo_path     = local.gitops_addons_path
      addons_repo_revision = local.gitops_addons_revision
    }
  )

  argocd_apps = {
    addons    = file("${path.module}/bootstrap/addons.yaml")
    workloads = file("${path.module}/bootstrap/workloads.yaml")
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/gitops-bridge-dev/gitops-bridge"
  }
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source = "github.com/gitops-bridge-dev/gitops-bridge-argocd-bootstrap-terraform?ref=v2.0.0"

  cluster = {
    cluster_name = module.eks.cluster_name
    environment  = local.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }
  apps = local.argocd_apps
  argocd = {
    namespace = local.argocd_namespace
  }
}

################################################################################
# ArgoCD EKS Access
################################################################################
module "argocd_irsa" {
  source = "aws-ia/eks-blueprints-addon/aws"

  create_release             = false
  create_role                = true
  role_name_use_prefix       = false
  role_name                  = "${module.eks.cluster_name}-argocd-hub"
  assume_role_condition_test = "StringLike"
  create_policy              = false
  role_policies = {
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
# EKS Blueprints Addons
################################################################################
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # Using GitOps Bridge
  create_kubernetes_resources = false

  # EKS Blueprints Addons
  enable_cert_manager                 = local.aws_addons.enable_cert_manager
  enable_aws_efs_csi_driver           = local.aws_addons.enable_aws_efs_csi_driver
  enable_aws_fsx_csi_driver           = local.aws_addons.enable_aws_fsx_csi_driver
  enable_aws_cloudwatch_metrics       = local.aws_addons.enable_aws_cloudwatch_metrics
  enable_aws_privateca_issuer         = local.aws_addons.enable_aws_privateca_issuer
  enable_cluster_autoscaler           = local.aws_addons.enable_cluster_autoscaler
  enable_external_dns                 = local.aws_addons.enable_external_dns
  enable_external_secrets             = local.aws_addons.enable_external_secrets
  enable_aws_load_balancer_controller = local.aws_addons.enable_aws_load_balancer_controller
  enable_fargate_fluentbit            = local.aws_addons.enable_fargate_fluentbit
  enable_aws_for_fluentbit            = local.aws_addons.enable_aws_for_fluentbit
  enable_aws_node_termination_handler = local.aws_addons.enable_aws_node_termination_handler
  enable_karpenter                    = local.aws_addons.enable_karpenter
  enable_velero                       = local.aws_addons.enable_velero
  enable_aws_gateway_api_controller   = local.aws_addons.enable_aws_gateway_api_controller

  tags = local.tags
}

################################################################################
# EKS Cluster
################################################################################
#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true


  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.medium"]

      min_size     = 3
      max_size     = 10
      desired_size = 3
    }
  }
  # EKS Addons
  cluster_addons = {
    vpc-cni = {
      # Specify the VPC CNI addon should be deployed before compute to ensure
      # the addon is configured before data plane compute resources are created
      # See README for further details
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }
  tags = local.tags
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

  tags = local.tags
}
