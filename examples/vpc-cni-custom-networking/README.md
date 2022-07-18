# EKS Cluster w/ VPC-CNI Custom Networking

This example shows how to provision an EKS cluster with:
- AWS VPC-CNI custom networking to assign IPs to pods from subnets outside of those used by the nodes
- AWS VPC-CNI prefix delegation to allow higher pod densities - this is useful since the custom networking removes one ENI from use for pod IP assignment which lowers the number of pods that can be assigned to the node. Enabling prefix delegation allows for prefixes to be assigned to the ENIs to ensure the node resources can be fully utilized through higher pod densitities. See the user data section below for managing the max pods assigned to the node.
- Dedicated /28 subnets for the EKS cluster control plane. Making changes to the subnets used by the control plane is a destructive operation - it is recommended to use dedicated subnets for the control plane that are separate from the data plane to allow for future growth through the addition of subnets without disruption to the cluster.

To disable prefix delegation from this example:

1. Remove the `--cni-prefix-delegation-enabled` flag from the user data script
2. Remove the environment environment variables `ENABLE_PREFIX_DELEGATION=true` and `WARM_PREFIX_TARGET=1` assignment from the `aws-node` daemonset (set in the `null_resource.kubectl_set_env` resource in this example)

## Reference Documentation:

- [Documentation](https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html)
- [Best Practices Guide](https://aws.github.io/aws-eks-best-practices/reliability/docs/networkmanagement/#cni-custom-networking)

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the deployment.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. List the nodes running currently

```sh
kubectl get nodes

# Output should look similar to below
NAME                                       STATUS   ROLES    AGE   VERSION
ip-10-0-34-74.us-west-2.compute.internal   Ready    <none>   86s   v1.22.9-eks-810597c
```

3. Inspect the nodes settings and check for the max allocatable pods - should be 110 in this scenario with m5.xlarge:

```sh
kubectl describe node ip-10-0-34-74.us-west-2.compute.internal

# Output should look similar to below (truncated for brevity)
  Capacity:
    attachable-volumes-aws-ebs:  25
    cpu:                         4
    ephemeral-storage:           104845292Ki
    hugepages-1Gi:               0
    hugepages-2Mi:               0
    memory:                      15919124Ki
    pods:                        110 # <- this should be 110 and not 58
  Allocatable:
    attachable-volumes-aws-ebs:  25
    cpu:                         3920m
    ephemeral-storage:           95551679124
    hugepages-1Gi:               0
    hugepages-2Mi:               0
    memory:                      14902292Ki
    pods:                        110 # <- this should be 110 and not 58
```

4. List out the pods running currently:

```sh
kubectl get pods -A -o wide

# Output should look similar to below
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE   IP            NODE                                       NOMINATED NODE   READINESS GATES
kube-system   aws-node-ttg4h             1/1     Running   0          52s   10.0.34.74    ip-10-0-34-74.us-west-2.compute.internal   <none>           <none>
kube-system   coredns-657694c6f4-8s5k6   1/1     Running   0          2m    10.99.135.1   ip-10-0-34-74.us-west-2.compute.internal   <none>           <none>
kube-system   coredns-657694c6f4-ntzcp   1/1     Running   0          2m    10.99.135.0   ip-10-0-34-74.us-west-2.compute.internal   <none>           <none>
kube-system   kube-proxy-wnzjd           1/1     Running   0          53s   10.0.34.74    ip-10-0-34-74.us-west-2.compute.internal   <none>           <none>
```

5. Inspect one of the `aws-node-*` (AWS VPC CNI) pods to ensure prefix delegation is enabled and warm prefix target is 1:

```sh
kubectl describe pod aws-node-ttg4h -n kube-system

# Output should look similar below (truncated for brevity)
  Environment:
    ADDITIONAL_ENI_TAGS:                    {}
    AWS_VPC_CNI_NODE_PORT_SUPPORT:          true
    AWS_VPC_ENI_MTU:                        9001
    AWS_VPC_K8S_CNI_CONFIGURE_RPFILTER:     false
    AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG:     true # <- this should be set to true
    AWS_VPC_K8S_CNI_EXTERNALSNAT:           false
    AWS_VPC_K8S_CNI_LOGLEVEL:               DEBUG
    AWS_VPC_K8S_CNI_LOG_FILE:               /host/var/log/aws-routed-eni/ipamd.log
    AWS_VPC_K8S_CNI_RANDOMIZESNAT:          prng
    AWS_VPC_K8S_CNI_VETHPREFIX:             eni
    AWS_VPC_K8S_PLUGIN_LOG_FILE:            /var/log/aws-routed-eni/plugin.log
    AWS_VPC_K8S_PLUGIN_LOG_LEVEL:           DEBUG
    DISABLE_INTROSPECTION:                  false
    DISABLE_METRICS:                        false
    DISABLE_NETWORK_RESOURCE_PROVISIONING:  false
    ENABLE_IPv4:                            true
    ENABLE_IPv6:                            false
    ENABLE_POD_ENI:                         false
    ENABLE_PREFIX_DELEGATION:               true # <- this should be set to true
    MY_NODE_NAME:                            (v1:spec.nodeName)
    WARM_ENI_TARGET:                        1 # <- this should be set to 1
    WARM_PREFIX_TARGET:                     1
    ...
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -target=kubectl_manifest.eni_config -target=module.eks_blueprints_kubernetes_addons -auto-approve
terraform destroy -target=module.eks_blueprints -auto-approve
terraform destroy -auto-approve
```
