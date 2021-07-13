# Windows Support

This example shows how to enable Windows support in the EKS cluster. 

## Required & recommended input

As of the time of writing of this document, Windows workloads cannot be deployed on AWS-managed EC2 or Fargate nodes. Self-managed nodes must be deployed for Windows workloads. This can be done using the following variables, as shown in the `eks-with-windows-support.tfvars` file:
```
# Enable self-managed nodegroup in the EKS cluster. Required. Default value is false.
enable_self_managed_nodegroups = true
# Enable Windows support. Required. Default value is false.
enable_windows_support         = true
# Windows self-managed nodegroup name. Recommended. Default value is "ng-linux".
self_managed_nodegroup_name    = "ng-windows"
```

## Optional input

The following variables are optional. Their default values are as shown below.
```
# Instance types
self_managed_node_instance_types = ["m5.large", "m5a.large", "m5n.large"]
# Root volume size of each node in GiB
self_managed_node_volume_size    = 50
# Desired capacity of the auto-scaling group
self_managed_node_desired_size   = 3
# Maximum capacity of the auto-scaling group
self_managed_node_max_size       = 3
# Minimum capacity of the auto-scaling group
self_managed_node_min_size       = 3
```

## See also

* [Windows support considerations](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html)
