# AWS for Fluent Bit

Fluent Bit is an open source Log Processor and Forwarder which allows you to collect any data like metrics and logs from different sources, enrich them with filters and send them to multiple destinations.

## AWS for Fluent Bit

AWS provides a Fluent Bit image with plugins for both CloudWatch Logs and Kinesis Data Firehose. The [AWS for Fluent Bit](https://github.com/aws/aws-for-fluent-bit) image is available on the Amazon ECR Public Gallery. For more details, see [aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit) on the Amazon ECR Public Gallery.

### Usage

[aws-for-fluent-bit](../../kubernetes-addons/aws-for-fluent-bit/README.md) can be deployed by enabling the add-on via the following.

```hcl
enable_aws_for_fluentbit = true
```

You can optionally customize the Helm chart that deploys `aws_for_fluentbit` via the following configuration.

```hcl
  aws_for_fluentbit_enable = true
  aws_for_fluentbit_helm_chart = {
    name                                      = "aws-for-fluent-bit"
    chart                                     = "aws-for-fluent-bit"
    repository                                = "https://aws.github.io/eks-charts"
    version                                   = "0.1.0"
    namespace                                 = "logging"
    aws_for_fluent_bit_cw_log_group           = "/${local.cluster_name}/worker-fluentbit-logs" # Optional
    aws_for_fluentbit_cwlog_retention_in_days = 90
    create_namespace                          = true
    values = [templatefile("${path.module}/values.yaml", {
      region                          = data.aws_region.current.name,
      aws_for_fluent_bit_cw_log_group = "/${local.cluster_name}/worker-fluentbit-logs"
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
