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

## Node selection for pods

Use [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) or [Node affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity) to deploy pods to either Windows or Linux nodes. The node label `kubernetes.io/os` can be used to select the nodes.

## Deployment & Testing

* Deploy the EKS cluster using the input variables as in `eks-with-windows-support.tfvars`, by following the [deployment steps](../../README.md#deployment-steps). 
* Verify Windows support in the cluster using a sample Windows pod deployment:
```bash
kubectl apply -f examples/windows-support/k8s/windows-iis.yaml
```
* Verify a Linux sample pod deployment:
```bash
kubectl apply -f examples/windows-support/k8s/linux-nginx.yaml
```

## See also

* [Windows support considerations](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html)
