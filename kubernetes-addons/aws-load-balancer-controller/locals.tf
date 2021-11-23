data "aws_region" "current" {}

locals {
  aws_load_balancer_controller_sa = "aws-load-balancer-controller-sa"

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    aws_region           = data.aws_region.current.name,
    cluster_name         = var.eks_cluster_id,
    service_account_name = local.aws_load_balancer_controller_sa
  })]

  default_lb_ingress_controller_helm_app = {
    name                       = "aws-load-balancer-controller"
    chart                      = "aws-load-balancer-controller"
    repository                 = "https://aws.github.io/eks-charts"
    version                    = "1.3.1"
    namespace                  = "kube-system"
    timeout                    = "1200"
    create_namespace           = false
    values                     = local.default_helm_values
    set                        = []
    set_sensitive              = null
    lint                       = true
    wait                       = true
    wait_for_jobs              = false
    description                = "aws-load-balancer-controller Helm Chart for ingress resources"
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

  lb_ingress_controller_helm_app = merge(
    local.default_lb_ingress_controller_helm_app,
    var.lb_ingress_controller_helm_app
  )

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.aws_load_balancer_controller_sa
  }
}
