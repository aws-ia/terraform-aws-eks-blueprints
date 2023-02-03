# kube-prometheus-stack
[kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)is a a collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator.

Components installed by this chart in this package by default:

  - [The Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
  - Highly available [Prometheus](https://github.com/prometheus/prometheus)
  - Highly available [Alertmanager](https://github.com/prometheus/alertmanager)
  - [Prometheus node-exporter](https://github.com/prometheus/node_exporter)
  - [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
  - [Grafana](https://github.com/grafana/grafana)


## Usage

The default values.yaml file in this add-on has disabled the components that are unreachable in EKS environments, and an EBS Volume for Persistent Storage.

You can override the defaults using the `set` helm_config key, and set the admin password with `set_sensitive`:

```hcl
  enable_kube_prometheus_stack      = true
  kube_prometheus_stack_helm_config = {
    set = [
      {
        name  = "kubeProxy.enabled"
        value = false
      }
    ],
    set_sensitive = [
      {
        name  = "grafana.adminPassword"
        value = data.aws_secretsmanager_secret_version.admin_password_version.secret_string
      }
    ]
  }
```

## Upgrading the Chart

Be aware that it is likely necessary to update the CRDs when updating the Chart version. Refer to the Project documentation on upgrades for your specific versions: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#upgrading-chart


For complete project documentation, please visit the [kube-prometheus-stack Github repository](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```hcl
kubePrometheusStack = {
  enable = true
}
```
