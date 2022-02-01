locals {
  transit_gateway_id = "tgw-08964eff8ffcadaf1"
  application_teams = {
    devopsoscar = {
      labels = {
        name = "devopsoscar",
      }
      quota = {
        "requests.cpu"    = "2000m",
        "requests.memory" = "8Gi",
        "limits.cpu"      = "4000m",
        "limits.memory"   = "16Gi",
        "pods"            = "20",
        "secrets"         = "20",
        "services"        = "20"
      }
      manifests_dir = "./manifests"
      users = [
        "arn:aws:iam::510522433898:role/eks-qa-admin-assume-role"
      ]
    }
  }
  platform_teams = {
    admin-team-name-example = {
      users = [
        "arn:aws:iam::510522433898:role/eks-qa-admin-assume-role"
      ]
    }
  }
}
