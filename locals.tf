locals {

  context = {
    # Data resources
    aws_region_name = data.aws_region.current.name
    # aws_caller_identity
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    # aws_partition
    aws_partition_id         = data.aws_partition.current.id
    aws_partition_dns_suffix = data.aws_partition.current.dns_suffix
  }

  # Managed node IAM Roles for aws-auth
  managed_node_group_aws_auth_config_map = [
    for role_arn in distinct(compact([for group in module.aws_eks.eks_managed_node_groups : group.iam_role_arn])) : {
      rolearn : role_arn
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]

  # Self Managed node IAM Roles for aws-auth
  self_managed_node_group_aws_auth_config_map = [
    for role_arn in distinct(compact([for group in module.aws_eks.self_managed_node_groups : group.iam_role_arn if group.platform != "windows"])) : {
      rolearn : role_arn
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]

  # Self Managed Windows node IAM Roles for aws-auth
  windows_node_group_aws_auth_config_map = [
    for role_arn in distinct(compact([for group in module.aws_eks.self_managed_node_groups : group.iam_role_arn if group.platform == "windows"])) : {
      rolearn : role_arn
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes",
        "eks:kube-proxy-windows"
      ]
    }
  ]

  # Fargate node IAM Roles for aws-auth
  fargate_profiles_aws_auth_config_map = [
    for role in distinct(compact([for profile in module.aws_eks.fargate_profiles : profile.fargate_profile_pod_execution_role_arn])) : {
      rolearn : role
      username : "system:node:{{SessionName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes",
        "system:node-proxier"
      ]
    }
  ]

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
      username : "${platform_team_name}"
      groups : [
        "system:masters"
      ]
    }
  ] : []

  # TODO - move this into `aws-eks-teams` to avoid getting out of sync
  application_teams_config_map = length(var.application_teams) > 0 ? [
    for team_name, team_data in var.application_teams : {
      rolearn : "arn:${local.partition}:iam::${local.account_id}:role/${module.aws_eks.cluster_id}-${team_name}-access"
      username : "${team_name}"
      groups : [
        "${team_name}-group"
      ]
    }
  ] : []

  cluster_iam_role_name = var.iam_role_name == null ? "${var.cluster_name}-cluster-role" : var.iam_role_name
}
