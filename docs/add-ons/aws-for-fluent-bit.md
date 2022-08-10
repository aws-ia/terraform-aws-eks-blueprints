# AWS for Fluent Bit

Fluent Bit is an open source Log Processor and Forwarder which allows you to collect any data like metrics and logs from different sources, enrich them with filters and send them to multiple destinations.

## AWS for Fluent Bit

AWS provides a Fluent Bit image with plugins for both CloudWatch Logs and Kinesis Data Firehose. The [AWS for Fluent Bit](https://github.com/aws/aws-for-fluent-bit) image is available on the Amazon ECR Public Gallery. For more details, see [aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit) on the Amazon ECR Public Gallery.

### Usage

[aws-for-fluent-bit](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/aws-for-fluentbit) can be deployed by enabling the add-on via the following.

This add-on is configured to stream the worker node logs to CloudWatch Logs by default. It can further be configured to stream the logs to additional destinations like Kinesis Data Firehose, Kinesis Data Streams and Amazon OpenSearch Service by passing the custom `values.yaml`.
See this [Helm Chart](https://github.com/aws/eks-charts/tree/master/stable/aws-for-fluent-bit) for more details.

```hcl
enable_aws_for_fluentbit = true
```

You can optionally customize the Helm chart that deploys `aws_for_fluentbit` via the following configuration.

```hcl
  enable_aws_for_fluentbit = true
  aws_for_fluentbit_irsa_policies = ["IAM Policies"] # Add list of additional policies to IRSA to enable access to Kinesis, OpenSearch etc.
  aws_for_fluentbit_cw_log_group_retention = 90
  aws_for_fluentbit_helm_config = {
    name                                      = "aws-for-fluent-bit"
    chart                                     = "aws-for-fluent-bit"
    repository                                = "https://aws.github.io/eks-charts"
    version                                   = "0.1.0"
    namespace                                 = "logging"
    aws_for_fluent_bit_cw_log_group           = "/${local.cluster_id}/worker-fluentbit-logs" # Optional
    create_namespace                          = true
    values = [templatefile("${path.module}/values.yaml", {
      region                          = data.aws_region.current.name,
      aws_for_fluent_bit_cw_log_group = "/${local.cluster_id}/worker-fluentbit-logs"
    })]
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```
awsForFluentBit = {
  enable       = true
  logGroupName = "<log_group_name>"
}
```
