# Vertical Pod Autoscaler
[VPA](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) Vertical Pod Autoscaler (VPA) automatically adjusts the CPU and memory reservations for your pods to help "right size" your applications. When configured, it will automatically request the necessary reservations based on usage and thus allow proper scheduling onto nodes so that the appropriate resource amount is available for each pod. It will also maintain ratios between limits and requests that were specified in initial container configuration.

NOTE: Metrics Server add-on is a dependency for this addon

## Usage

This step deploys the Vertical Pod Autoscaler with default Helm Chart config

```hcl
  vpa_enable = true
```

Alternatively, you can override the helm values by using the code snippet below

```hcl
  vpa_enable = true

  vpa_helm_chart = {
    name       = "vpa"                                 # (Required) Release name.
    repository = "https://charts.fairwinds.com/stable" # (Optional) Repository URL where to locate the requested chart.
    chart      = "vpa"                                 # (Required) Chart name to be installed.
    version    = "0.5.0"                               # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
    namespace  = "vpa-ns"                              # (Optional) The namespace to install the release into. Defaults to default
    values     = [templatefile("${path.module}/k8s_addons/vpa-values.yaml", {})]
  }
```
