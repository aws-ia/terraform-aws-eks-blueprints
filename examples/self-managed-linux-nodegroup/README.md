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
```

By default, the latest EKS-optimized Amazon Linux 2 AMI will be used. You can provide a custom AMI as follows:
```
self_managed_node_ami_id = "ami-12345678901234567"
```

By default, the user data script template in `source/templates/userdata-amazonlinux2eks.tpl` will be used. You can use a custom user data script as follows:
```
self_managed_node_userdata_template_file = "./path/to/my-template.tpl"
```

Default list of user data template parameters includes the following:
* cluster_name - The cluster's name
* cluster_ca_base64 - The cluster's base64-encoded certifying authority data
* cluster_endpoint - The cluster's K8s API server endpoint
* pre_userdata - Script snippet to be executed before running the main user data script
* additional_userdata - Script snippet to be executed after running the main user data script 
* bootstrap_extra_args - Extra arguments for the bootstrap script (where applicable)
* kubelet_extra_args - Extra arguments for kubelet

You can optionally provide additional parameters as follows:
```
self_managed_node_userdata_template_extra_params = { my_param = "my_value" }
```

## Node selection for pods

Use [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) or [Node affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity) to deploy pods correctly to either (AWS-)managed or self-managed Linux nodes. The node label `WorkerType` can be used to select the nodes.

## Deployment & Testing

* Deploy an EKS cluster by following the [deployment steps](../../README.md#deployment-steps). 
* Verify a Linux sample pod deployment on the self-managed nodes:
```bash
kubectl apply -f examples/self-managed-linux-nodegroup/k8s/linux-nginx.yaml
```
