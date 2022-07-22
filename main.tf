# ---------------------------------------------------------------------------------------------------------------------
# CLUSTER KMS KEY
# ---------------------------------------------------------------------------------------------------------------------
module "kms" {
  count  = var.create_eks && var.cluster_kms_key_arn == null ? 1 : 0
  source = "./modules/aws-kms"

  alias                   = "alias/${var.cluster_name}"
  description             = "${var.cluster_name} EKS cluster secret encryption key"
  policy                  = data.aws_iam_policy_document.eks_key.json
  deletion_window_in_days = var.cluster_kms_key_deletion_window_in_days
  tags                    = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS CONTROL PLANE
# ---------------------------------------------------------------------------------------------------------------------
module "aws_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "v18.26.6"

  create = var.create_eks

  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  cluster_timeouts = var.cluster_timeouts

  # IAM Role
  create_iam_role = var.create_iam_role
  iam_role_arn    = var.iam_role_arn

  iam_role_use_name_prefix      = false
  iam_role_name                 = local.cluster_iam_role_name
  iam_role_path                 = var.iam_role_path
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  iam_role_additional_policies  = var.iam_role_additional_policies

  # EKS Cluster VPC Config
  subnet_ids                           = var.private_subnet_ids
  control_plane_subnet_ids             = var.control_plane_subnet_ids
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Kubernetes Network Config
  cluster_ip_family         = var.cluster_ip_family
  cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr

  # Cluster Security Group
  create_cluster_security_group           = var.create_cluster_security_group
  cluster_security_group_id               = var.cluster_security_group_id
  vpc_id                                  = var.vpc_id
  cluster_additional_security_group_ids   = var.cluster_additional_security_group_ids
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  cluster_security_group_tags             = var.cluster_security_group_tags

  # Worker Node Security Group
  create_node_security_group           = var.create_node_security_group
  node_security_group_additional_rules = var.node_security_group_additional_rules
  node_security_group_tags             = var.node_security_group_tags

  # IRSA
  enable_irsa              = var.enable_irsa # no change
  openid_connect_audiences = var.openid_connect_audiences
  custom_oidc_thumbprints  = var.custom_oidc_thumbprints

  # TAGS
  tags = var.tags

  # CLUSTER LOGGING
  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cluster_enabled_log_types              = var.cluster_enabled_log_types # no change
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id

  # CLUSTER ENCRYPTION
  attach_cluster_encryption_policy = false
  cluster_encryption_config = length(var.cluster_encryption_config) == 0 ? [
    {
      provider_key_arn = try(module.kms[0].key_arn, var.cluster_kms_key_arn)
      resources        = ["secrets"]
    }
  ] : var.cluster_encryption_config

  cluster_identity_providers = var.cluster_identity_providers
}

# ---------------------------------------------------------------------------------------------------------------------
# Amazon EMR on EKS Virtual Clusters
# ---------------------------------------------------------------------------------------------------------------------
module "emr_on_eks" {
  source = "./modules/emr-on-eks"

  for_each = { for key, value in var.emr_on_eks_teams : key => value
    if var.enable_emr_on_eks && length(var.emr_on_eks_teams) > 0
  }

  emr_on_eks_teams              = each.value
  eks_cluster_id                = module.aws_eks.cluster_id
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  tags                          = var.tags

  depends_on = [kubernetes_config_map.aws_auth]
}

resource "kubernetes_config_map" "amazon_vpc_cni" {
  count = var.enable_windows_support ? 1 : 0
  metadata {
    name      = "amazon-vpc-cni"
    namespace = "kube-system"
  }

  data = {
    "enable-windows-ipam" = var.enable_windows_support ? "true" : "false"
  }

  depends_on = [
    module.aws_eks.cluster_id,
    data.http.eks_cluster_readiness[0]
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Teams
# ---------------------------------------------------------------------------------------------------------------------
module "aws_eks_teams" {
  count  = length(var.application_teams) > 0 || length(var.platform_teams) > 0 ? 1 : 0
  source = "./modules/aws-eks-teams"

  application_teams             = var.application_teams
  platform_teams                = var.platform_teams
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  eks_cluster_id                = module.aws_eks.cluster_id
  tags                          = var.tags
}
