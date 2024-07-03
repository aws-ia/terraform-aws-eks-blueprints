module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_argocd = true
  argocd = {
    namespace     = "argocd"
    chart_version = "7.1.0" # ArgoCD v2.11.2
    values = [
      templatefile("${path.module}/values/argocd.yaml", {
        ecr_account_id                        = local.ecr_account_id
        ecr_region                            = local.ecr_region
    })]
  }

  enable_metrics_server = true
  metrics_server = {
    values = [
      templatefile("${path.module}/values/metrics-server.yaml", {
        ecr_account_id = local.ecr_account_id
        ecr_region     = local.ecr_region
    })]
  }

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    values = [
      templatefile("${path.module}/values/aws-load-balancer-controller.yaml", {
        ecr_account_id = local.ecr_account_id
        ecr_region     = local.ecr_region
    })]
  }

  enable_kube_prometheus_stack = true
  kube_prometheus_stack = {
    values = [
      templatefile("${path.module}/values/prometheus.yaml", {
        ecr_account_id = local.ecr_account_id
        ecr_region     = local.ecr_region
    })]
  }

  depends_on = [module.eks.cluster_addons]
}

resource "time_sleep" "addons_wait_60_seconds" {
  create_duration = "60s"
  depends_on      = [module.eks_blueprints_addons]
}

#---------------------------------------------------------------
# Gatekeeper
#---------------------------------------------------------------
module "gatekeeper" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  name             = "gatekeeper"
  description      = "A Helm chart to deploy gatekeeper project"
  namespace        = "gatekeeper-system"
  create_namespace = true
  chart            = "gatekeeper"
  chart_version    = "3.16.3"
  repository       = "https://open-policy-agent.github.io/gatekeeper/charts"
  values = [
    templatefile("${path.module}/values/gatekeeper.yaml", {
      ecr_account_id = local.ecr_account_id
      ecr_region     = local.ecr_region
  })]

  depends_on = [time_sleep.addons_wait_60_seconds]
}
