# Fluent Bit

Fluent Bit is an open source Log Processor and Forwarder which allows you to collect any data like metrics and logs from different sources, enrich them with filters and send them to multiple destinations.

## AWS for Fluent Bit

AWS provides a Fluent Bit image with plugins for both CloudWatch Logs and Kinesis Data Firehose. The [AWS for Fluent Bit](https://github.com/aws/aws-for-fluent-bit) image is available on the Amazon ECR Public Gallery. For more details, see [aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit) on the Amazon ECR Public Gallery.

### Usage

[aws-for-fluent-bit](../../kubernetes-addons/aws-for-fluent-bit/README.md) can be deployed by enabling the add-on via the following.

```hcl
aws_for_fluentbit_enable = true
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```
awsForFluentBit = {
  enable       = true
  logGroupName = "<log_group_name>"
}
```
