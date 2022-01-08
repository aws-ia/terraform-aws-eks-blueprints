data "aws_eks_cluster" "my-cluster" {
  name = module.aws-eks-accelerator-for-terraform.cluster_name
}

data "aws_eks_cluster_auth" "my-auth" {
  name = module.aws-eks-accelerator-for-terraform.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.my-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.my-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.my-auth.token
}

resource "kubernetes_service_account" "gitlab-admin" {
  metadata {
    name      = "gitlab-admin"
    namespace = "kube-system"
  }
  depends_on = [module.aws-eks-accelerator-for-terraform]
}

resource "kubernetes_secret" "gitlab-admin" {
  metadata {
    name      = "gitlab-admin"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.gitlab-admin.metadata.0.name
    }
  }
  lifecycle {
    ignore_changes = [
      data
    ]
  }
  type = "kubernetes.io/service-account-token"

  depends_on = [module.aws-eks-accelerator-for-terraform]
}

data "kubernetes_secret" "gitlab-admin-token" {
  metadata {
    name      = kubernetes_service_account.gitlab-admin.default_secret_name
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "gitlab-admin" {
  metadata {
    name = "gitlab-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "gitlab-admin"
    namespace = "kube-system"
  }

  depends_on = [module.aws-eks-accelerator-for-terraform]
}
