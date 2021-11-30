locals {
  team_manifests = flatten([
    for team_name, team_data in var.teams :
    fileset(path.root, "${team_data.manifests_dir}/*")
  ])

  eks_oidc_issuer_url   = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  eks_oidc_provider_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"

}
