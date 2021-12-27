## Fluent Bit for Fargate

[Fluent Bit for Fargate](https://aws.amazon.com/blogs/containers/fluent-bit-for-amazon-eks-on-aws-fargate-is-here/) configures Fluent Bit to forward Fargate Container logs to CloudWatch.

### Usage

Fluent Bit for Fargate can be deployed by enabling the add-on via the following.

```hcl
enable_fargate_fluentbit = true
```
