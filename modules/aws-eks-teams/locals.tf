locals {
  partition             = data.aws_partition.current.partition
  account_id            = data.aws_caller_identity.current.account_id
  eks_oidc_issuer_url   = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  eks_oidc_provider_arn = "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
  role_prefix_name      = format("%s-%s-%s", var.tenant, var.environment, var.zone)

  team_manifests = flatten([
    for team_name, team_data in var.application_teams :
    try(fileset(path.root, "${team_data.manifests_dir}/*"), [])
  ])

  platform_teams_config_map = length(var.platform_teams) > 0 ? [
    for platform_team_name, platform_team_data in var.platform_teams : {
      rolearn : "arn:${local.partition}:iam::${local.account_id}:role/${format("%s-%s-%s", local.role_prefix_name, "${platform_team_name}", "Access")}"
      username : "${platform_team_name}"
      groups : [
        "system:masters"
      ]
    }
  ] : []

  application_teams_config_map = length(var.application_teams) > 0 ? [
    for team_name, team_data in var.application_teams : {
      rolearn : "arn:${local.partition}:iam::${local.account_id}:role/${format("%s-%s-%s", local.role_prefix_name, "${team_name}", "Access")}"
      username : "${team_name}"
      groups : [
        "${team_name}-group"
      ]
    }
  ] : []

}
