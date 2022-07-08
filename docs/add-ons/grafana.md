# Grafana

[Grafana](https://github.com/grafana/grafana) is an open source platform for monitoring and observability.

Grafana addon can be deployed with EKS blueprints in Amazon EKS server.
This add-on configures [Prometheus](https://grafana.com/docs/grafana/latest/datasources/prometheus/) and [CloudWatch](https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/) data sources.
You can add more data sources using the [values.yaml](https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml)

## Usage

[Grafana](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/spark-k8s-operator) can be deployed by enabling the add-on via the following. This example shows the usage of the Secrets Manager to create a new secret for Grafana adminPassword.

This option sets a default `adminPassword` by the helm chart which can be extracted from kubernetes `secrets` with the name as `grafana`.  
```
enable_grafana = true
```

You can optionally customize the Helm chart that deploys `Grafana` via the following configuration.
Also, provide the `adminPassword` using set_sensitive values as shown in the example

```
  enable_grafana = true
  grafana_irsa_policies = [] # Optional to add additional policies to IRSA

# Optional  karpenter_helm_config
  grafana_helm_config = {
    name        = "grafana"
    chart       = "grafana"
    repository  = "https://grafana.github.io/helm-charts"
    version     = "6.32.1"
    namespace   = "grafana"
    description = "Grafana Helm Chart deployment configuration"
    values = [templatefile("${path.module}/values.yaml", {})]
    set_sensitive = [
      {
        name  = "adminPassword"
        value = "<YOUR_SECURE_PASSWORD_FOR_GARFANA_ADMIN>"
      }
    ]
  }

```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```
grafana = {
  enable = true
}
```
