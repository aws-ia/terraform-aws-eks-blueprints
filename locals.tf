locals {

  context = {
    # Data resources
    aws_region_name = data.aws_region.current.name
    # aws_caller_identity
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_iam_session_context.current.issuer_arn
    # aws_partition
    aws_partition_id         = data.aws_partition.current.id
    aws_partition_dns_suffix = data.aws_partition.current.dns_suffix
  }

  eks_cluster_id     = module.aws_eks.cluster_id
  cluster_ca_base64  = module.aws_eks.cluster_certificate_authority_data
  cluster_endpoint   = module.aws_eks.cluster_endpoint
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids

  enable_workers            = length(var.self_managed_node_groups) > 0 || length(var.managed_node_groups) > 0 ? true : false
  worker_security_group_ids = local.enable_workers ? compact(flatten([[module.aws_eks.node_security_group_id], var.worker_additional_security_group_ids])) : []

  node_group_context = {
    # EKS Cluster Config
    eks_cluster_id    = local.eks_cluster_id
    cluster_ca_base64 = local.cluster_ca_base64
    cluster_endpoint  = local.cluster_endpoint
    cluster_version   = var.cluster_version
    # VPC Config
    vpc_id             = local.vpc_id
    private_subnet_ids = local.private_subnet_ids
    public_subnet_ids  = local.public_subnet_ids

    # Worker Security Group
    worker_security_group_ids = local.worker_security_group_ids

    # Data sources
    aws_partition_dns_suffix = local.context.aws_partition_dns_suffix
    aws_partition_id         = local.context.aws_partition_id

    iam_role_path                 = var.iam_role_path
    iam_role_permissions_boundary = var.iam_role_permissions_boundary

    # Service IPv4/IPv6 CIDR range
    service_ipv6_cidr = var.cluster_service_ipv6_cidr
    service_ipv4_cidr = var.cluster_service_ipv4_cidr

    tags = var.tags
  }

  fargate_context = {
    eks_cluster_id                = local.eks_cluster_id
    aws_partition_id              = local.context.aws_partition_id
    iam_role_path                 = var.iam_role_path
    iam_role_permissions_boundary = var.iam_role_permissions_boundary
    tags                          = var.tags
  }

  # Managed node IAM Roles for aws-auth
  managed_node_group_aws_auth_config_map = length(var.managed_node_groups) > 0 == true ? [
    for key, node in var.managed_node_groups : {
      rolearn : try(node.iam_role_arn, "arn:${local.context.aws_partition_id}:iam::${local.context.aws_caller_identity_account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}")
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ] : []

  # Self Managed node IAM Roles for aws-auth
  self_managed_node_group_aws_auth_config_map = length(var.self_managed_node_groups) > 0 ? [
    for key, node in var.self_managed_node_groups : {
      rolearn : try(node.iam_role_arn, "arn:${local.context.aws_partition_id}:iam::${local.context.aws_caller_identity_account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}")
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    } if node.launch_template_os != "windows"
  ] : []

  # Self Managed Windows node IAM Roles for aws-auth
  windows_node_group_aws_auth_config_map = length(var.self_managed_node_groups) > 0 && var.enable_windows_support ? [
    for key, node in var.self_managed_node_groups : {
      rolearn : "arn:${local.context.aws_partition_id}:iam::${local.context.aws_caller_identity_account_id}:role/${module.aws_eks.cluster_id}-${node.node_group_name}"
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes",
        "eks:kube-proxy-windows"
      ]
    } if node.launch_template_os == "windows"
  ] : []

  # Fargate node IAM Roles for aws-auth
  fargate_profiles_aws_auth_config_map = length(var.fargate_profiles) > 0 ? [
    for key, node in var.fargate_profiles : {
      rolearn : try(node.iam_role_arn, "arn:${local.context.aws_partition_id}:iam::${local.context.aws_caller_identity_account_id}:role/${module.aws_eks.cluster_id}-${node.fargate_profile_name}")
      username : "system:node:{{SessionName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes",
        "system:node-proxier"
      ]
    }
  ] : []

  # EMR on EKS IAM Roles for aws-auth
  emr_on_eks_config_map = var.enable_emr_on_eks == true ? [
    {
      rolearn : "arn:${local.context.aws_partition_id}:iam::${local.context.aws_caller_identity_account_id}:role/AWSServiceRoleForAmazonEMRContainers"
      username : "emr-containers"
      groups : []
    }
  ] : []

  # Teams
  partition  = local.context.aws_partition_id
  account_id = local.context.aws_caller_identity_account_id

  # TODO - move this into `aws-eks-teams` to avoid getting out of sync
  platform_teams_config_map = length(var.platform_teams) > 0 ? [
    for platform_team_name, platform_team_data in var.platform_teams : {
      rolearn : "arn:${local.partition}:iam::${local.account_id}:role/${module.aws_eks.cluster_id}-${platform_team_name}-access"
      username : platform_team_name
      groups : [
        "system:masters"
      ]
    }
  ] : []

  # TODO - move this into `aws-eks-teams` to avoid getting out of sync
  application_teams_config_map = length(var.application_teams) > 0 ? [
    for team_name, team_data in var.application_teams : {
      rolearn : "arn:${local.partition}:iam::${local.account_id}:role/${module.aws_eks.cluster_id}-${team_name}-access"
      username : team_name
      groups : [
        "${team_name}-group"
      ]
    }
  ] : []

  cluster_iam_role_name        = var.iam_role_name == null ? "${var.cluster_name}-cluster-role" : var.iam_role_name
  cluster_iam_role_pathed_name = var.iam_role_path == null ? local.cluster_iam_role_name : "${trimprefix(var.iam_role_path, "/")}${local.cluster_iam_role_name}"
  cluster_iam_role_pathed_arn  = var.create_iam_role ? "arn:${local.context.aws_partition_id}:iam::${local.context.aws_caller_identity_account_id}:role/${local.cluster_iam_role_pathed_name}" : var.iam_role_arn
}
