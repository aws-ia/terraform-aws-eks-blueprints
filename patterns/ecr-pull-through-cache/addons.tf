locals {
  ecr_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_argocd = true
  argocd = {
    values = [<<-EOT
      global:
        image:
          repository: ${local.ecr_url}/quay/argoproj/argocd
      dex:
        image:
          repository: ${local.ecr_url}/docker-hub/dexidp/dex
      haproxy:
        image:
          repository: ${local.ecr_url}/docker-hub/library/haproxy
    EOT
    ]
  }

  enable_metrics_server = true
  metrics_server = {
    set = [{
      name  = "image.repository"
      value = "${local.ecr_url}/k8s/metrics-server/metrics-server"
      }
    ]
  }

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [{
      name  = "image.repository"
      value = "${local.ecr_url}/ecr/eks/aws-load-balancer-controller"
      }
    ]
  }

  enable_kube_prometheus_stack = true
  kube_prometheus_stack = {
    values = [<<-EOT
      global:
        imageRegistry: ${local.ecr_url}
      prometheusOperator:
        image:
          repository: quay/prometheus-operator/prometheus-operator
        admissionWebhooks:
          deployment:
            image:
              repository: quay/prometheus-operator/admission-webhook
          patch:
            image:
              repository: k8s/ingress-nginx/kube-webhook-certgen
        prometheusConfigReloader:
          image:
            repository: quay/prometheus-operator/prometheus-config-reloader
      alertmanager:
        alertmanagerSpec:
          image:
            repository: quay/prometheus/alertmanager
      prometheus:
        prometheusSpec:
          image:
            repository: quay/prometheus/prometheus
      prometheus-node-exporter:
        image:
          repository: quay/prometheus/node-exporter
      kube-state-metrics:
        image:
          repository: k8s/kube-state-metrics/kube-state-metrics
      grafana:
        global:
          imageRegistry: ${local.ecr_url}
        downloadDashboardsImage:
          repository: ${local.ecr_url}/docker-hub/curlimages/curl
        image:
          repository: ${local.ecr_url}/quay/grafana/grafana
        imageRenderer:
          repository: ${local.ecr_url}/quay/grafana/grafana-image-renderer
        sidecar:
          image:
            repository: ${local.ecr_url}/quay/kiwigrid/k8s-sidecar
    EOT
    ]
  }

  depends_on = [module.eks.cluster_addons]
}

module "gatekeeper" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.1"

  name             = "gatekeeper"
  description      = "A Helm chart to deploy gatekeeper project"
  namespace        = "gatekeeper-system"
  create_namespace = true
  chart            = "gatekeeper"
  chart_version    = "3.16.3"
  repository       = "https://open-policy-agent.github.io/gatekeeper/charts"
  values = [<<-EOT
    image:
      repository: ${local.ecr_url}/docker-hub/openpolicyagent/gatekeeper
      crdRepository: ${local.ecr_url}/docker-hub/openpolicyagent/gatekeeper-crds
    postUpgrade:
      labelNamespace:
        image:
          repository: ${local.ecr_url}/docker-hub/openpolicyagent/gatekeeper-crds
      postInstall:
        labelNamespace:
          image:
            repository: ${local.ecr_url}/docker-hub/openpolicyagent/gatekeeper-crds
      probeWebhook:
        image:
          repository: ${local.ecr_url}/docker-hub/curlimages/curl
      preUninstall:
        deleteWebhookConfigurations:
          image:
            repository: ${local.ecr_url}/docker-hub/openpolicyagent/gatekeeper-crds

  EOT
  ]

  depends_on = [module.eks.cluster_addons]
}
