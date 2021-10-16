# Fargate Fluent Bit Logger

Amazon EKS on Fargate offers a built-in log router based on Fluent Bit.
This means that you don't explicitly run a Fluent Bit container as a sidecar, but Amazon runs it for you.
All that you have to do is configure the log router.
The configuration happens through a dedicated ConfigMap that must meet the following criteria:

Named `aws-logging`

Created in a dedicated namespace called `aws-observability`

Once you've created the ConfigMap, Amazon EKS on Fargate automatically detects it and configures the log router with it.
Fargate uses a version of AWS for Fluent Bit, an upstream compliant distribution of Fluent Bit managed by AWS.
For more information, see AWS for Fluent Bit on GitHub.

The log router allows you to use the breadth of services at AWS for log analytics and storage.
You can stream logs from Fargate directly to `Amazon CloudWatch`, `Amazon OpenSearch Service`.
You can also stream logs to destinations such as `Amazon S3`, `Amazon Kinesis Data Streams`, and partner tools through Amazon Kinesis Data Firehose.

# Fluent Bit CloudWatch Config
Please find the updated configuration from [AWS Docs](https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html)

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: aws-logging
  namespace: aws-observability
data:
  output.conf: |
    [OUTPUT]
        Name cloudwatch_logs
        Match   *
        region us-east-1
        log_group_name fluent-bit-cloudwatch
        log_stream_prefix from-fluent-bit-
        auto_create_group true

  parsers.conf: |
    [PARSER]
        Name crio
        Format Regex
        Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>P|F) (?<log>.*)$
        Time_Key    time
        Time_Format %Y-%m-%dT%H:%M:%S.%L%z

  filters.conf: |
     [FILTER]
        Name parser
        Match *
        Key_name log
        Parser crio
        Reserve_Data On
        Preserve_Key On
```
