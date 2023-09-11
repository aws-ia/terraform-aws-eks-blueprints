---
title: IPv4 Prefix Delegation
---

The configuration snippet below shows how to enable prefix delegation to increase the number of available IP addresses on the provisioned EC2 nodes.

- [Documentation](https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html)
- [Blog post](https://aws.amazon.com/blogs/containers/amazon-vpc-cni-increases-pods-per-node-limits/)

## VPC CNI Configuration

In this example, the `vpc-cni` addon is configured using `before_compute = true`. This is done to ensure the `vpc-cni` is created and updated *before* any EC2 instances are created so that the desired settings have applied before they will be referenced. With this configuration, you will now see that nodes created will have `--max-pods 110` configured do to the use of prefix delegation being enabled on the `vpc-cni`.

If you find that your nodes are not being created with the correct number of max pods (i.e. - for `m5.large`, if you are seeing a max pods of 29 instead of 110), most likely the `vpc-cni` was not configured *before* the EC2 instances.

```json
module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  # Truncated for brevity
  ...

  cluster_addons = {
    vpc-cni = {
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  ...
}
```

When enabled, inspect one of the `aws-node-*` (AWS VPC CNI) pods to ensure prefix delegation is enabled and warm prefix target is 1:

```sh
kubectl describe ds -n kube-system aws-node | grep ENABLE_PREFIX_DELEGATION: -A 3
```

Output should look similar to below (truncated for brevity):

```yaml
    ENABLE_PREFIX_DELEGATION:               true # <- this should be set to true
    WARM_ENI_TARGET:                        1
    WARM_PREFIX_TARGET:                     1 # <- this should be set to 1
    ...
```
