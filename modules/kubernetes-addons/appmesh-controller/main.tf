locals {
  name      = try(var.helm_config.name, "appmesh-controller")
  namespace = try(var.helm_config.namespace, "appmesh-system")

  dns_suffix = data.aws_partition.current.dns_suffix

  argocd_gitops_config = {
    {
      enable             = true
      serviceAccountName = local.name
    }
}

data "aws_partition" "current" {}

module "helm_addon" {
  source = "../helm-addon"

  helm_config = merge(
    {
      name        = local.name
      chart       = "appmesh-controller"
      repository  = "https://aws.github.io/eks-charts"
      version     = "1.10.0"
      namespace   = local.namespace
      description = "AWS App Mesh Helm Chart"
    },
    var.helm_config
  )

  set_values = concat([
    {
      name  = "serviceAccount.name"
      value = local.name
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
    ],
    try(var.helm_config.set_values, [])
  )

  irsa_config = {
    create_kubernetes_namespace         = try(var.helm_config.create_namespace, true)
    kubernetes_namespace                = try(var.helm_config.namespace, local.namespace)
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(var.helm_config["create_service_account_secret_token"], false)
    kubernetes_service_account          = try(var.helm_config.service_account, local.name)
    irsa_iam_policies                   = concat([aws_iam_policy.this.arn], var.irsa_policies)
  }

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "this" {
  name        = "${var.addon_context.eks_cluster_id}-appmesh"
  description = "IAM Policy for App Mesh"
  policy      = data.aws_iam_policy_document.this.json
}
