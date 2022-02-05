locals {
  namespace            = "karpenter"
  service_account_name = "karpenter"
  eks_cluster_endpoint = data.aws_eks_cluster.eks.endpoint

  karpenter_set_values = [{
    name  = "serviceAccount.name"
    value = local.service_account_name
    },
    {
      name  = "serviceAccount.create"
      value = false
    },
    {
      name  = "controller.clusterName"
      value = var.eks_cluster_id
    },
    {
      name  = "controller.clusterEndpoint"
      value = local.eks_cluster_endpoint
    },
    {
      name  = "aws.defaultInstanceProfile"
      value = var.node_iam_instance_profile
    }
  ]

  default_helm_config = {
    name                       = "karpenter"
    chart                      = "karpenter"
    repository                 = "https://charts.karpenter.sh"
    version                    = "0.5.6"
    namespace                  = local.namespace
    timeout                    = "300"
    create_namespace           = false
    values                     = local.default_helm_values
    set                        = []
    set_sensitive              = null
    lint                       = true
    wait                       = true
    wait_for_jobs              = false
    description                = "karpenter Helm Chart for Node Autoscaling"
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

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    eks_cluster_id            = var.eks_cluster_id,
    eks_cluster_endpoint      = local.eks_cluster_endpoint,
    service_account_name      = local.service_account_name,
    node_iam_instance_profile = var.node_iam_instance_profile,
    operating_system          = "linux"
  })]

  argocd_gitops_config = {
    enable                    = true
    serviceAccountName        = local.service_account_name
    controllerClusterName     = var.eks_cluster_id
    controllerClusterEndpoint = local.eks_cluster_endpoint
    awsDefaultInstanceProfile = var.node_iam_instance_profile
  }
}
