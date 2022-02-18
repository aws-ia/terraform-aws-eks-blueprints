locals {
  name                 = "aws-efs-csi-driver"
  service_account_name = "efs-csi-sa"
  namespace            = "kube-system"

  default_helm_config = {
    name                       = local.name
    chart                      = local.name
    repository                 = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
    version                    = "2.2.3"
    namespace                  = local.namespace
    timeout                    = "1200"
    create_namespace           = false
    values                     = local.default_helm_values
    set                        = []
    set_sensitive              = null
    lint                       = true
    wait                       = true
    wait_for_jobs              = false
    description                = "The AWS EFS CSI driver Helm chart deployment configuration"
    verify                     = false
    keyring                    = ""
    repository_key_file        = ""
    repository_cert_file       = ""
    repository_ca_file         = ""
    repository_username        = ""
    repository_password        = ""
    disable_webhooks           = false
    reuse_values               = false
    reset_values               = false
    force_update               = false
    recreate_pods              = false
    cleanup_on_fail            = false
    max_history                = 0
    atomic                     = false
    skip_crds                  = false
    render_subchart_notes      = true
    disable_openapi_validation = false
    dependency_update          = false
    replace                    = false
    postrender                 = ""
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = []

  # Disable service account creation as that's handled by the IRSA add-on module
  set_values = [
    {
      name  = "controller.serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "controller.serviceAccount.create"
      value = false
    },
    {
      name  = "node.serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "node.serviceAccount.create"
      value = false
    }
  ]

  irsa_config = {
    kubernetes_namespace              = local.namespace
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = false
    create_kubernetes_service_account = true
    iam_role_path                     = "/"
    eks_cluster_id                    = var.eks_cluster_id
    irsa_iam_policies                 = concat([aws_iam_policy.aws_efs_csi_driver.arn], var.irsa_policies)
    irsa_iam_permissions_boundary     = var.irsa_iam_permissions_boundary
    tags                              = var.tags
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
}
