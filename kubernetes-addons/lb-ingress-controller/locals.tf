data "aws_region" "current" {}

locals {
  aws_lb_controller_sa = "aws-load-balancer-controller"

  default_lb_ingress_controller_helm_app = {
    name             = "aws-lb-ingress-controller"
    chart            = "aws-load-balancer-controller"
    repository       = "https://aws.github.io/eks-charts"
    version          = "1.3.1"
    namespace        = "kube-system"
    timeout          = "1200"
    create_namespace = false
    values = [templatefile("${path.module}/lb-ingress-controller.yaml", {
      region               = data.aws_region.current.name,
      image                = "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon/aws-load-balancer-controller"
      tag                  = "v2.3.0"
      clusterName          = var.eks_cluster_id
      aws_lb_controller_sa = local.aws_lb_controller_sa
      replicaCount         = "1"
    })]
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      },
      {
        name  = "serviceAccount.create"
        value = "false"
      },
      {
        name  = "serviceAccount.name"
        value = local.aws_lb_controller_sa
      }
    ]
    set_sensitive              = null
    lint                       = true
    wait                       = true
    wait_for_jobs              = false
    description                = "aws-lb-ingress-controller Helm Chart for ingress resources"
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
  var.lb_ingress_controller_helm_app)
}
