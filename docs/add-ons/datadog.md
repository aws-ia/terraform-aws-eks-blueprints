# Datadog
The [Datadog Agent](https://docs.datadoghq.com/agent/) is software that runs on your hosts.
It collects events and metrics from hosts and sends them to Datadog, where you can analyze your monitoring and performance data. The Datadog Agent is open source and its source code is available on GitHub at DataDog/datadog-agent.


## Usage
This step deploys the Datadog K8s with default Helm Chart config

```hcl
  enable_datadog = true
```

Alternatively, you can override the helm values by using the code snippet below

```hcl
  enable_datadog = true

  datadog_helm_config = {
    name       = "datadog"                                 # (Required) Release name.
    repository = "https://helm.datadoghq.com" # (Optional) Repository URL where to locate the requested chart.
    chart      = "datadog"                                 # (Required) Chart name to be installed.
    version    = "3.1.1"                               # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/datadog/locals.tf
    values     = [templatefile("${path.module}/values.yaml", {})]
  }
```
