# Apache YuniKorn
[YuniKorn](https://yunikorn.apache.org/) YuniKorn is a light-weight, universal resource scheduler for container orchestrator systems.

Apache YuniKorn (Incubating) is a new Apache incubator project that offers rich scheduling capabilities on Kubernetes. It fills the scheduling gap while running Big Data workloads on Kubernetes, with a ton of useful features such as hierarchical queues, elastic queue quotas, resource fairness, and job ordering

You can define `batchScheduler: "yunikorn"` when you are running Spark Applications using SparkK8sOperator

## Usage
This step deploys the Apache YuniKorn K8s schedular with default Helm Chart config

```hcl
  yunikorn_enable = true
```

Alternatively, you can override the helm values by using the code snippet below

```hcl
  yunikorn_enable = true

  yunikorn_helm_chart = {
    name       = "yunikorn"                                 # (Required) Release name.
    repository = "https://apache.github.io/incubator-yunikorn-release" # (Optional) Repository URL where to locate the requested chart.
    chart      = "yunikorn"                                 # (Required) Chart name to be installed.
    version    = "0.12.0"                               # (Optional) Specify the exact chart version to install. If this is not specified, the latest version is installed.
    values     = [templatefile("${path.module}/values.yaml", {})]
  }
```
