locals {
  name                 = "velero"
  service_account_name = local.name

  default_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://vmware-tanzu.github.io/helm-charts/"
    version     = "2.23.6"
    namespace   = local.name
    description = "Velero AddOn Helm Chart"
    values      = local.default_helm_values
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    sa-name = local.service_account_name
  })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  # Set serviceAccount.create to False explicity
  # even if its set to true in customer provided values.yaml
  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.service_account_name
    }
  ]

  # An IRSA config must be passed
  irsa_config = {
    kubernetes_namespace              = local.name
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    iam_role_path                     = "/"
    tags                              = var.addon_context.tags
    eks_cluster_id                    = var.addon_context.eks_cluster_id
    irsa_iam_policies                 = concat([aws_iam_policy.velero_policy.arn], var.irsa_policies)
    irsa_iam_permissions_boundary     = var.irsa_permissions_boundary
  }

  # If you would like customers to be able to use GitOps via ArgoCD
  # open a PR in the https://github.com/aws-samples/ssp-eks-add-ons/
  # repo in order to create an ArgoCD application for your addon.
  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
