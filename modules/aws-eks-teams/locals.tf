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

  compute_hard_quota_list = ["requests.cpu", "requests.memory", "limits.cpu", "limits.memory"]
  team_compute_hard_quotas = {
    for team_name, team_data in var.application_teams : team_name => {
      for quota_name in setintersection(local.compute_hard_quota_list, keys(team_data.quota)) : quota_name => team_data.quota[quota_name]
    } if length(setintersection(local.compute_hard_quota_list, keys(try(team_data.quota, {})))) > 0
  }

  object_hard_quota_list = ["pods", "secrets", "services"]
  team_object_hard_quotas = {
    for team_name, team_data in var.application_teams : team_name => {
      for quota_name in setintersection(local.object_hard_quota_list, keys(team_data.quota)) : quota_name => team_data.quota[quota_name]
    } if length(setintersection(local.object_hard_quota_list, keys(try(team_data.quota, {})))) > 0
  }
}
