data "gitlab_group" "gitops-eks" {
  full_path = "ssp-amazon-eks-terraform-group"
}

data "gitlab_projects" "ssp-amazon-eks" {
  group_id          = data.gitlab_group.gitops-eks.id
  simple            = true
  search            = "ssp-amazon-eks"
  include_subgroups = true
}

resource "gitlab_group_cluster" "aws_cluster" {
  group                 = data.gitlab_group.gitops-eks.id
  name                  = module.aws-eks-accelerator-for-terraform.cluster_name
  domain                = ""
  environment_scope     = "*"
  kubernetes_api_url    = module.aws-eks-accelerator-for-terraform.cluster_endpoint
  kubernetes_token      = data.kubernetes_secret.gitlab-admin-token.data.token
  kubernetes_ca_cert    = trimspace(base64decode(module.aws-eks-accelerator-for-terraform.cluster_certificate_authority_data))
  management_project_id = data.gitlab_projects.ssp-amazon-eks.projects.0.id

  depends_on = [module.aws-eks-accelerator-for-terraform]
}
