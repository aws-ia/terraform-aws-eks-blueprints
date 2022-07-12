# kube-prometheus-stack
[kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)is a a collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator.


## Usage

The default values.yaml file in this add-on has disabled the components that are unreachable in EKS environments.

You can override the defaults using the `set` helm_config key:

```
  enable_kube_prometheus_stack      = true
  kube_prometheus_stack_helm_config = {
    set = [
      {
        name  = "kubeProxy.enabled"
        value = false
      }
    ]  
  }
```

## Upgrading the Chart

Be aware that it is likely necessary to update the CRDs when updating the Chart version. Refer to the Project documentation on upgrades for your specific versions: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#upgrading-chart


For complete project documentation, please visit the [kube-prometheus-stack Github repository](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).
