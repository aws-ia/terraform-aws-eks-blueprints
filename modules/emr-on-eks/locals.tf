
locals {
  default_emr_on_eks_teams = {
    emr_on_eks_username      = "emr-containers"
    emr_on_eks_namespace     = "spark"
    emr_on_eks_iam_role_name = "EMRonEKSExecution"
  }
  emr_on_eks_team = merge(
    local.default_emr_on_eks_teams,
    var.emr_on_eks_teams
  )
}
