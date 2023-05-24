# Vertical Pod Autoscaler
[VPA](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) Vertical Pod Autoscaler (VPA) automatically adjusts the CPU and memory reservations for your pods to help "right size" your applications. When configured, it will automatically request the necessary reservations based on usage and thus allow proper scheduling onto nodes so that the appropriate resource amount is available for each pod. It will also maintain ratios between limits and requests that were specified in initial container configuration.

NOTE: Metrics Server add-on is a dependency for this addon

## Usage

This step deploys the Vertical Pod Autoscaler with default Helm Chart config

```hcl
  enable_vpa            = true
  enable_metrics_server = true
```

You can also customize the Helm chart that deploys `vpa` via the following configuration:

```hcl
  enable_vpa = true
  enable_metrics_server = true

  vpa = {
    name          = "vpa"
    chart_version = "1.7.5"
    repository    = "https://charts.fairwinds.com/stable"
    namespace     = "vpa"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }
```
