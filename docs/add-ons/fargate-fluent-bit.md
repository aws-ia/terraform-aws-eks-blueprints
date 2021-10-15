## Fluent Bit for Fargate

The [fargate-fluent-bit](https://aws.amazon.com/blogs/containers/fluent-bit-for-amazon-eks-on-aws-fargate-is-here/) configures Fluent Bit to ship the Fargate Container logs to CloudWatch

### Usage 

fargate-fluent-bit can be deployed by enabling the add-on via the following.

```hcl
fargate_fluent_bit_enable = true
```