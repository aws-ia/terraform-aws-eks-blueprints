# EKS w/ ML Capacity Block Reservation (CBR)

This pattern demonstrates how to consume/utilize ML capacity block reservations (CBR) with Amazon EKS. The solution is comprised of primarily of the following components:

1. EKS managed node group that will utilize the CBR should have the subnets provided to it restricted to the availability zone where the CBR has been allocated. For example - if the CBR is allocated to `us-west-2b`, the node group should only have subnet IDs provided to it that reside in `us-west-2b`. If the subnets that reside in other AZs are provided, its possible to encounter an error such as `InvalidParameterException: The following supplied instance types do not exist ...`. It is not guaranteed that this error will always be shown, and may appear random since the underlying autoscaling group(s) will provision nodes into different AZs at random. It will only occur when the underlying autoscaling group tries to provision instances into an AZ where capacity is not allocated and there is insufficient on-demand capacity for the desired instance type.
2. The launch template utilized should specify the `instance_market_options` and `capacity_reservation_specification` arguments. This is how the CBR is utilized by the node group (i.e. - tells the autoscaling group to launch instances utilizing provided capacity reservation).
3. In the case of EKS managed node group(s), the `capacity_type` should be set to `"CAPACITY_BLOCK"`.

<b>Links:</b>

- [EKS - Capacity Blocks for ML](https://docs.aws.amazon.com/eks/latest/userguide/capacity-blocks.html)
- [EC2 - Capacity Blocks for ML](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-capacity-blocks.html)

## Code

```terraform hl_lines="5-11 99-113"
{% include  "../../patterns/ml-capacity-block/eks.tf" %}
```

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
