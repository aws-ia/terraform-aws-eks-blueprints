locals {
  region = "us-west-2"
}

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.hub.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.hub.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.hub.token
}

data "aws_eks_cluster" "hub" {
  name = var.hub_cluster_name
}

data "aws_eks_cluster_auth" "hub" {
  name = var.hub_cluster_name
}

data "aws_eks_cluster" "spoke" {
  name = "spoke-cluster"
}

data "aws_caller_identity" "current" {}

resource "kubernetes_secret_v1" "spoke_cluster" {
  metadata {
    name      = "spoke-cluster"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" : "cluster"
    }
  }
  data = {
    server = data.aws_eks_cluster.spoke.endpoint
    name   = "spoke-cluster"
    config = jsonencode(
      {
        execProviderConfig : {
          apiVersion : "client.authentication.k8s.io/v1beta1",
          command : "argocd-k8s-auth",
          args : [
            "aws",
            "--cluster-name",
            "spoke-cluster",
            "--role-arn",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/spoke-role"
          ],
          env : {
            AWS_REGION : local.region
          }
        },
        tlsClientConfig : {
          insecure : false,
          caData : data.aws_eks_cluster.spoke.certificate_authority[0].data
        }
      }
    )
  }
}