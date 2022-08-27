# Promtail

Promtail is an agent which ships the contents of local logs to a Loki instance.

[Promtail](https://github.com/grafana/helm-charts/tree/main/charts/promtail) chart bootstraps Promtail infrastructure on a Kubernetes cluster using the Helm package manager.

For complete project documentation, please visit the [Promtail documentation site](https://grafana.com/docs/loki/latest/clients/promtail/).

## Usage

Promtail can be deployed by enabling the add-on via the following.

```hcl
enable_promtail = true
```

Deploy Promtail with custom `values.yaml`

```hcl
  # Optional Map value; pass promtail-values.yaml from consumer module
  promtail_helm_config = {
    name       = "promtail"                                               # (Required) Release name.
    repository = "https://grafana.github.io/helm-charts"                  # (Optional) Repository URL where to locate the requested chart.
    chart      = "promtail"                                               # (Required) Chart name to be installed.
    version    = "6.3.0"                                                  # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/promtail/locals.tf
    namespace  = "promtail"                                               # (Optional) The namespace to install the release into.
    values = [templatefile("${path.module}/promtail-values.yaml", {})]
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```hcl
promtail = {
  enable = true
}
```
