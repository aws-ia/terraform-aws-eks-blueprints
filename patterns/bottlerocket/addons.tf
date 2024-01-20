################################################################################
# EKS Blueprints Addons
################################################################################
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.12"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_cert_manager = true
  cert_manager = {
    wait          = true
    wait_for_jobs = true
  }

  enable_karpenter = true
  karpenter = {
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
    version             = "v0.33"
  }

  tags = local.tags
}

################################################################################
# Karpenter resources
################################################################################
resource "helm_release" "karpenter_resources" {
  name  = "karpenter-resources"
  chart = "./karpenter-resources"
  set_list {
    name  = "nodepool.zone"
    value = local.azs
  }

  depends_on = [module.eks_blueprints_addons]
}

module "bottlerocket_update_operator_crds" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1.1"

  description   = "CRDs for Bottlerocket Update Operator"
  chart         = "bottlerocket-shadow"
  chart_version = "1.0.0"
  repository    = "https://bottlerocket-os.github.io/bottlerocket-update-operator/"

  depends_on = [module.eks_blueprints_addons]
}

module "bottlerocket_update_operator" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1.1"

  description      = "A Helm chart for Bottlerocket Update Operator"
  chart            = "bottlerocket-update-operator"
  chart_version    = "1.3.0"
  namespace        = "brupop-bottlerocket-aws"
  create_namespace = true
  repository       = "https://bottlerocket-os.github.io/bottlerocket-update-operator/"
  set = [{
    name  = "scheduler_cron_expression"
    value = "0 0 23 * * Sat *" # Perform update checks every Saturday at 23H / 11PM
  }]

  depends_on = [module.eks_blueprints_addons]
}
