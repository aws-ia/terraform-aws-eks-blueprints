# AWS CloudWatch Metrics

Use CloudWatch Container Insights to collect, aggregate, and summarize metrics and logs from your containerized applications and microservices. CloudWatch automatically collects metrics for many resources, such as CPU, memory, disk, and network. Container Insights also provides diagnostic information, such as container restart failures, to help you isolate issues and resolve them quickly. You can also set CloudWatch alarms on metrics that Container Insights collects.

Container Insights collects data as performance log events using embedded metric format. These performance log events are entries that use a structured JSON schema that enables high-cardinality data to be ingested and stored at scale. From this data, CloudWatch creates aggregated metrics at the cluster, node, pod, task, and service level as CloudWatch metrics. The metrics that Container Insights collects are available in CloudWatch automatic dashboards, and also viewable in the Metrics section of the CloudWatch console.

## Usage

[aws-cloudwatch-metrics](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/aws-cloudwatch-metrics) can be deployed by enabling the add-on via the following.

```hcl
enable_aws_cloudwatch_metrics = true
```

You can also customize the Helm chart that deploys `aws-cloudwatch-metrics` via the following configuration:


```hcl
  enable_aws_cloudwatch_metrics        = true

  aws_cloudwatch_metrics_irsa_policies = ["IAM Policies"]
  aws_cloudwatch_metrics   = {
    role_policies = ["IAM Policies"]  # extra policies in addition of CloudWatchAgentServerPolicy
    name          = "aws-cloudwatch-metrics"
    repository    = "https://aws.github.io/eks-charts"
    chart_version = "0.0.9"
    namespace     = "amazon-cloudwatch"
    values        = [templatefile("${path.module}/values.yaml", {})] # The value `clusterName` is already set to the EKS cluster name, no need to specify here
  }
```
