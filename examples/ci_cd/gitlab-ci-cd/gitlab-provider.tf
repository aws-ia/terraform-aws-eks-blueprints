
# data source for an existing GitLab group
data "gitlab_group" "gitops-eks" {
  group_id = var.group_id
}

resource "gitlab_group_cluster" "aws_cluster" {
  group                 = data.gitlab_group.gitops-eks.id
  name                  = module.aws-eks-accelerator-for-terraform.eks_cluster_id
  kubernetes_api_url    = data.aws_eks_cluster.cluster.endpoint
  kubernetes_token      = data.kubernetes_secret.gitlab-admin-token.data.token
  kubernetes_ca_cert    = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  management_project_id = var.gitlab_project_id

  depends_on = [module.aws-eks-accelerator-for-terraform]
}
