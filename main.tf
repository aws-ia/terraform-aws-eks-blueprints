data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "http" "eks_cluster_readiness" {
  count = var.create ? 1 : 0

  url            = "${module.eks.cluster_endpoint}/healthz"
  ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  timeout        = var.eks_readiness_timeout
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS CONTROL PLANE
# ---------------------------------------------------------------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "v18.29.0"

  create = var.create

  cluster_name               = var.cluster_name
  cluster_version            = var.cluster_version
  cluster_timeouts           = var.cluster_timeouts
  cluster_identity_providers = var.cluster_identity_providers

  # Data plane
  eks_managed_node_groups          = var.eks_managed_node_groups
  eks_managed_node_group_defaults  = var.eks_managed_node_group_defaults
  fargate_profiles                 = var.fargate_profiles
  fargate_profile_defaults         = var.fargate_profile_defaults
  self_managed_node_groups         = var.self_managed_node_groups
  self_managed_node_group_defaults = var.self_managed_node_group_defaults

  # IAM Role
  create_iam_role               = var.create_iam_role
  iam_role_arn                  = var.iam_role_arn
  iam_role_name                 = var.iam_role_name
  iam_role_use_name_prefix      = var.iam_role_use_name_prefix
  iam_role_path                 = var.iam_role_path
  iam_role_description          = var.iam_role_description
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  iam_role_additional_policies  = var.iam_role_additional_policies
  cluster_iam_role_dns_suffix   = var.cluster_iam_role_dns_suffix
  iam_role_tags                 = var.iam_role_tags

  # Network
  subnet_ids                           = var.subnet_ids
  control_plane_subnet_ids             = var.control_plane_subnet_ids
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Kubernetes Network
  cluster_ip_family          = var.cluster_ip_family
  cluster_service_ipv4_cidr  = var.cluster_service_ipv4_cidr
  create_cni_ipv6_iam_policy = var.create_cni_ipv6_iam_policy

  # Cluster Security Group
  vpc_id                                  = var.vpc_id
  create_cluster_security_group           = var.create_cluster_security_group
  cluster_security_group_id               = var.cluster_security_group_id
  cluster_security_group_name             = var.cluster_security_group_name
  cluster_security_group_use_name_prefix  = var.cluster_security_group_use_name_prefix
  cluster_security_group_description      = var.cluster_security_group_description
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  cluster_security_group_tags             = var.cluster_security_group_tags
  cluster_additional_security_group_ids   = var.cluster_additional_security_group_ids

  # Worker Node Security Group
  create_node_security_group              = var.create_node_security_group
  node_security_group_id                  = var.node_security_group_id
  node_security_group_name                = var.node_security_group_name
  node_security_group_use_name_prefix     = var.node_security_group_use_name_prefix
  node_security_group_description         = var.node_security_group_description
  node_security_group_additional_rules    = var.node_security_group_additional_rules
  node_security_group_tags                = var.node_security_group_tags
  node_security_group_ntp_ipv4_cidr_block = var.node_security_group_ntp_ipv4_cidr_block
  node_security_group_ntp_ipv6_cidr_block = var.node_security_group_ntp_ipv6_cidr_block

  # IRSA
  enable_irsa              = var.enable_irsa
  openid_connect_audiences = var.openid_connect_audiences
  custom_oidc_thumbprints  = var.custom_oidc_thumbprints

  # Logging
  cluster_enabled_log_types              = var.cluster_enabled_log_types
  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id

  # Encryption
  cluster_encryption_config                 = var.cluster_encryption_config
  attach_cluster_encryption_policy          = var.attach_cluster_encryption_policy
  cluster_encryption_policy_name            = var.cluster_encryption_policy_name
  cluster_encryption_policy_use_name_prefix = var.cluster_encryption_policy_use_name_prefix
  cluster_encryption_policy_description     = var.cluster_encryption_policy_description
  cluster_encryption_policy_path            = var.cluster_encryption_policy_path
  cluster_encryption_policy_tags            = var.cluster_encryption_policy_tags
  create_kms_key                            = var.create_kms_key
  kms_key_description                       = var.kms_key_description
  kms_key_deletion_window_in_days           = var.kms_key_deletion_window_in_days
  enable_kms_key_rotation                   = var.enable_kms_key_rotation
  kms_key_enable_default_policy             = var.kms_key_enable_default_policy
  kms_key_owners                            = var.kms_key_owners
  kms_key_administrators                    = var.kms_key_administrators
  kms_key_users                             = var.kms_key_users
  kms_key_service_users                     = var.kms_key_service_users
  kms_key_source_policy_documents           = var.kms_key_source_policy_documents
  kms_key_override_policy_documents         = var.kms_key_override_policy_documents
  kms_key_aliases                           = var.kms_key_aliases

  # Tags
  tags                                       = var.tags
  cluster_tags                               = var.cluster_tags
  create_cluster_primary_security_group_tags = var.create_cluster_primary_security_group_tags
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
  eks_cluster_id                = module.eks.cluster_id
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
    module.eks.cluster_id,
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
  eks_cluster_id                = module.eks.cluster_id
  tags                          = var.tags
}
