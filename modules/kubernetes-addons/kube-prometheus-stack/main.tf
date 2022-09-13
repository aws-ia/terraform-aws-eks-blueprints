module "helm_addon" {
  source            = "../helm-addon"
  helm_config       = local.helm_config
  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
  irsa_config       = null

  depends_on = [
    kubernetes_namespace_v1.prometheus,
    kubectl_manifest.prometheus_crd_alertmanagerconfigs,
    kubectl_manifest.prometheus_crd_alertmanagers,
    kubectl_manifest.prometheus_crd_podmonitors,
    kubectl_manifest.prometheus_crd_probes,
    kubectl_manifest.prometheus_crd_prometheuses,
    kubectl_manifest.prometheus_crd_prometheusrules,
    kubectl_manifest.prometheus_crd_servicemonitors,
    kubectl_manifest.prometheus_crd_thanosrulers
  ]
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata {
    name = local.helm_config["namespace"]
    labels = {
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
    }
  }
}

resource "kubectl_manifest" "prometheus_crd_alertmanagerconfigs" {
  yaml_body         = data.http.prometheus_crd_alertmanagerconfigs.response_body
  server_side_apply = true
}

resource "kubectl_manifest" "prometheus_crd_alertmanagers" {
  yaml_body         = data.http.prometheus_crd_alertmanagers.response_body
  server_side_apply = true
}

resource "kubectl_manifest" "prometheus_crd_podmonitors" {
  yaml_body         = data.http.prometheus_crd_podmonitors.response_body
  server_side_apply = true
}

resource "kubectl_manifest" "prometheus_crd_probes" {
  yaml_body         = data.http.prometheus_crd_probes.response_body
  server_side_apply = true
}

resource "kubectl_manifest" "prometheus_crd_prometheuses" {
  yaml_body         = data.http.prometheus_crd_prometheuses.response_body
  server_side_apply = true
}

resource "kubectl_manifest" "prometheus_crd_prometheusrules" {
  yaml_body         = data.http.prometheus_crd_prometheusrules.response_body
  server_side_apply = true
}

resource "kubectl_manifest" "prometheus_crd_servicemonitors" {
  yaml_body         = data.http.prometheus_crd_servicemonitors.response_body
  server_side_apply = true
}

resource "kubectl_manifest" "prometheus_crd_thanosrulers" {
  yaml_body         = data.http.prometheus_crd_thanosrulers.response_body
  server_side_apply = true
}

data "http" "prometheus_crd_alertmanagerconfigs" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.helm_config.version}/charts/kube-prometheus-stack/crds/crd-alertmanagerconfigs.yaml"
}

data "http" "prometheus_crd_alertmanagers" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.helm_config.version}/charts/kube-prometheus-stack/crds/crd-alertmanagers.yaml"
}

data "http" "prometheus_crd_podmonitors" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.helm_config.version}/charts/kube-prometheus-stack/crds/crd-podmonitors.yaml"
}

data "http" "prometheus_crd_probes" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.helm_config.version}/charts/kube-prometheus-stack/crds/crd-probes.yaml"
}

data "http" "prometheus_crd_prometheuses" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.helm_config.version}/charts/kube-prometheus-stack/crds/crd-prometheuses.yaml"
}

data "http" "prometheus_crd_prometheusrules" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.helm_config.version}/charts/kube-prometheus-stack/crds/crd-prometheusrules.yaml"
}

data "http" "prometheus_crd_servicemonitors" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.helm_config.version}/charts/kube-prometheus-stack/crds/crd-servicemonitors.yaml"
}

data "http" "prometheus_crd_thanosrulers" {
  url = "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.helm_config.version}/charts/kube-prometheus-stack/crds/crd-thanosrulers.yaml"
}