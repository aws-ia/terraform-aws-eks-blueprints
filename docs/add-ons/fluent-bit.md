## Fluent Bit

[Fluent Bit](https://fluentbit.io/) is an open source Log Processor and Forwarder which allows you to collect any data like metrics and logs from different sources, enrich them with filters and send them to multiple destinations.

This framework supports multiple FluentBit configuration which integrate with the various types of compute the framework deploys.

## AWS for Fluent Bit

[aws-for-fluent-bit](helm/aws-for-fluent-bit/README.md) can be deployed by specifying the following line in `base.tfvars` file.
AWS provides a Fluent Bit image with plugins for both CloudWatch Logs and Kinesis Data Firehose. The AWS for Fluent Bit image is available on the Amazon ECR Public Gallery.

For more details, see [aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit) on the Amazon ECR Public Gallery.

```hcl
aws-for-fluent-bit_enable = true`
```

## Fargate Fluent Bit

[fargate-fluentbit](helm/fargate_fluentbit) can be deployed by specifying the following line in `base.tfvars` file.
This module ships the Fargate Container logs to CloudWatch

```hcl
fargate_fluent_bit_enable = true`
```
