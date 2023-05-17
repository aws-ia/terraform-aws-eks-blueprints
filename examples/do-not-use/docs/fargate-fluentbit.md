# Fargate Fluentbit

Amazon EKS on Fargate offers a built-in log router based on Fluent Bit. This means that you don't explicitly run a Fluent Bit container as a sidecar, but Amazon runs it for you. All that you have to do is configure the log router. The configuration happens through a dedicated ConfigMap, that is deployed via this Add-on.

## Usage

To configure the Fargate Fluentbit ConfigMap via the [EKS Blueprints Addons](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons), just reference the following parameters under the `module.eks_blueprints_addons`.

```hcl
module "eks_blueprints_addons" {

  enable_fargate_fluentbit = true
  fargate_fluentbit = {
    flb_log_cw = true
  }
}
```

It's possible to customize the CloudWatch Log Group parameters in the `fargate_fluentbit_cw_log_group` configuration block:

```hcl
  fargate_fluentbit_cw_log_group = {

  name              = "existing-log-group"
  name_prefix       = "dev-environment-logs"
  retention_in_days = 7
  kms_key_id        = "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  skip_destroy      = true
```

## Validation

1. Check if the `aws-logging` configMap for Fargate Fluentbit was created.

```sh
kubectl -n aws-observability get configmap aws-logging -o yaml
apiVersion: v1
data:
  filters.conf: |
    [FILTER]
      Name parser
      Match *
      Key_Name log
      Parser regex
      Preserve_Key True
      Reserve_Data True
  flb_log_cw: "true"
  output.conf: |
    [OUTPUT]
      Name cloudwatch_logs
      Match *
      region us-west-2
      log_group_name /fargate-serverless/fargate-fluentbit-logs20230509014113352200000006
      log_stream_prefix fargate-logs-
      auto_create_group true
  parsers.conf: |
    [PARSER]
      Name regex
      Format regex
      Regex ^(?<time>[^ ]+) (?<stream>[^ ]+) (?<logtag>[^ ]+) (?<message>.+)$
      Time_Key time
      Time_Format %Y-%m-%dT%H:%M:%S.%L%z
      Time_Keep On
      Decode_Field_As json message
immutable: false
kind: ConfigMap
metadata:
  creationTimestamp: "2023-05-08T21:14:52Z"
  name: aws-logging
  namespace: aws-observability
  resourceVersion: "1795"
  uid: d822bcf5-a441-4996-857e-7fb1357bc07e
```

2. Validate if the CloudWatch LogGroup was created accordingly, and LogStreams were populated.

```sh
aws logs describe-log-groups --log-group-name-prefix "/fargate-serverless/fargate-fluentbit"
{
    "logGroups": [
        {
            "logGroupName": "/fargate-serverless/fargate-fluentbit-logs20230509014113352200000006",
            "creationTime": 1683580491652,
            "retentionInDays": 90,
            "metricFilterCount": 0,
            "arn": "arn:aws:logs:us-west-2:111122223333:log-group:/fargate-serverless/fargate-fluentbit-logs20230509014113352200000006:*",
            "storedBytes": 0
        }
    ]
}
```

```sh
aws logs describe-log-streams --log-group-name "/fargate-serverless/fargate-fluentbit-logs20230509014113352200000006" --log-stream-name-prefix fargate-logs --query 'logStreams[].logStreamName'
[
    "fargate-logs-flblogs.var.log.fluent-bit.log",
    "fargate-logs-kube.var.log.containers.aws-load-balancer-controller-7f989fc6c-grjsq_kube-system_aws-load-balancer-controller-feaa22b4cdaa71ecfc8355feb81d4b61ea85598a7bb57aef07667c767c6b98e4.log",
    "fargate-logs-kube.var.log.containers.aws-load-balancer-controller-7f989fc6c-wzr46_kube-system_aws-load-balancer-controller-69075ea9ab3c7474eac2a1696d3a84a848a151420cd783d79aeef960b181567f.log",
    "fargate-logs-kube.var.log.containers.coredns-7b7bddbc85-8cxvq_kube-system_coredns-9e4f3ab435269a566bcbaa606c02c146ad58508e67cef09fa87d5c09e4ac0088.log",
    "fargate-logs-kube.var.log.containers.coredns-7b7bddbc85-gcjwp_kube-system_coredns-11016818361cd68c32bf8f0b1328f3d92a6d7b8cf5879bfe8b301f393cb011cc.log"
]
```

## Resources

[AWS Docs](https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html)
[Fluent Bit for Amazon EKS on AWS Fargate Blog Post](https://aws.amazon.com/blogs/containers/fluent-bit-for-amazon-eks-on-aws-fargate-is-here/)