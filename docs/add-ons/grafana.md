# Grafana

[Grafana](https://github.com/grafana/grafana) is an open source platform for monitoring and observability. 

Grafana addon can be deployed with EKS blueprints in Amazon EKS server. 
This add-on configures [Prometheus](https://grafana.com/docs/grafana/latest/datasources/prometheus/) and [CloudWatch](https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/) data sources. 
You can add more data sources using the [values.yaml](https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml)

## Usage

[Grafana](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/spark-k8s-operator) can be deployed by enabling the add-on via the following.

```
enable_grafana = true

# grafana_admin_password_secret_name is an optional parameter but its recommended for security best practise.
# Checkout the above usage example to create secrets on the fly by Terraform

grafana_admin_password_secret_name = <aws_secrets_manager_secret_name> 
```

You can optionally customize the Helm chart that deploys `Grafana` via the following configuration.

```hcl
  enable_grafana = true
  grafana_admin_password_secret_name = "<aws_secrets_manager_secret_name>"
  grafana_irsa_policies = [] # Optional to add additional policies to IRSA

# Optional  karpenter_helm_config
  grafana_helm_config = {
    name        = local.name
    chart       = local.name
    repository  = "https://grafana.github.io/helm-charts"
    version     = "6.32.1"
    namespace   = local.name
    description = "Grafana Helm Chart deployment configuration"
    values = [templatefile("${path.module}/values.yaml", {})]
  }

```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```
grafana = {
  enable = true
}
```
