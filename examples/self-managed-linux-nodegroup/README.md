# Self-managed Linux node group

This example shows how to deploy a self-managed Linux node group in the EKS cluster. 

## Required input

As shown in the `eks-with-self-managed-linux-nodegroup.tfvars` file, the only required input is to enable self-managed nodegroups in the cluster. 
```
# Enable self-managed nodegroup in the EKS cluster. Required. Default value is false.
enable_self_managed_nodegroups = true
```

## Optional input

The following variables are optional. Their default values are as shown below.
```
# Linux self-managed nodegroup name.
self_managed_nodegroup_name      = "ng-linux"
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

Use [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) or [Node affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity) to deploy pods correctly to either (AWS-)managed or self-managed Linux nodes. The node label `WorkerType` can be used to select the nodes.

## Deployment & Testing

* Deploy an EKS cluster by following the [deployment steps](../../README.md#deployment-steps). 
* Verify a Linux sample pod deployment on the self-managed nodes:
```bash
kubectl apply -f examples/self-managed-linux-nodegroup/k8s/linux-nginx.yaml
```
