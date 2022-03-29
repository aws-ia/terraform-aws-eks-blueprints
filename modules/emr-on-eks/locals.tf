locals {
  default_emr_on_eks_teams = {
    emr_on_eks_namespace     = "emr-on-eks-spark"
    emr_on_eks_iam_role_name = "emr-on-eks-spark-iam-role"
  }
  emr_on_eks_team = merge(
    local.default_emr_on_eks_teams,
    var.emr_on_eks_teams
  )
  emr_service_name = "emr-containers"
}
