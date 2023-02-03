locals {
  partition             = data.aws_partition.current.partition
  account_id            = data.aws_caller_identity.current.account_id
  eks_oidc_issuer_url   = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  eks_oidc_provider_arn = "arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"

  team_manifests = flatten([
    for team_name, team_data in var.application_teams :
    try(fileset(path.root, "${team_data.manifests_dir}/*"), [])
  ])

}
