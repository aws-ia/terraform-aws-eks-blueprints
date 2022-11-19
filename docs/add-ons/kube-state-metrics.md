# Kube-State-Metrics

[kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) (KSM) is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.

The metrics are exported on the HTTP endpoint /metrics on the listening port (default 8080). They are served as plaintext. They are designed to be consumed either by Prometheus itself or by a scraper that is compatible with scraping a Prometheus client endpoint.

This add-on is implemented as an external add-on. For detailed documentation and usage of the add-on please refer to the add-on [repository](https://github.com/askulkarni2/terraform-eksblueprints-kube-state-metrics-addon).

## Usage

The following will deploy the KSM into an EKS Cluster.

```hcl-terraform
enable_kube_state_metrics = true
```

Enable KSM with custom `values.yaml`

```hcl-terraform
  enable_kube_state_metrics = true

  # Optional Map value
  kube_state_metrics_helm_config = {
    name       = "kube-state-metrics" # (Required) Release name.
    repository = "https://prometheus-community.github.io/helm-charts" # (Optional) Repository URL where to locate the requested chart.
    chart      = "kube-state-metrics" # (Required) Chart name to be installed.
    version    = "4.5.0"
    namespace  = "kube-state-metrics"
    values = [templatefile("${path.module}/values.yaml", {}})]
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```hcl-terraform
argocd_gitops_config = {
  enable             = true
  serviceAccountName = local.service_account
}
```
