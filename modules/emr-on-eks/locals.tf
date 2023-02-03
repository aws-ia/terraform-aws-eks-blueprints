locals {

  default_emr_eks_team = {
    namespace               = "emr-on-eks-spark"
    job_execution_role      = "emr-on-eks-job-role"
    additional_iam_policies = []
  }

  emr_on_eks_team = merge(
    local.default_emr_eks_team,
    var.emr_on_eks_teams
  )

  emr_service_name = "emr-containers"
}
