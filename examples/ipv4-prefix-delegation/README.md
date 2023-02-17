# EKS Cluster w/ Prefix Delegation

This example shows how to provision an EKS cluster with prefix delegation enabled for increasing the number of available IP addresses for the EC2 nodes utilized.

- [Documentation](https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html)
- [Blog post](https://aws.amazon.com/blogs/containers/amazon-vpc-cni-increases-pods-per-node-limits/)

## VPC CNI Configuration

In this example, the `vpc-cni` addon is configured using `before_compute = true`. This is done to ensure the `vpc-cni` is created and updated *before* any EC2 instances are created so that the desired settings have applied before they will be referenced. With this configuration, you will now see that nodes created will have `--max-pods 110` configured do to the use of prefix delegation being enabled on the `vpc-cni`.

If you find that your nodes are not being created with the correct number of max pods (i.e. - for `m5.large`, if you are seeing a max pods of 29 instead of 110), most likely the `vpc-cni` was not configured *before* the EC2 instances.

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

# Output should look like below
NAME                                        STATUS                        ROLES    AGE     VERSION
ip-10-0-30-125.us-west-2.compute.internal   Ready                         <none>   2m19s   v1.22.9-eks-810597c
```

3. Inspect the nodes settings and check for the max allocatable pods - should be 110 in this scenario with m5.xlarge:

```sh
kubectl describe node ip-10-0-30-125.us-west-2.compute.internal

# Output should look like below (truncated for brevity)
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
kubectl get pods -A

# Output should look like below
NAMESPACE     NAME                       READY   STATUS        RESTARTS   AGE
kube-system   aws-node-77rwz             1/1     Running       0          6m5s
kube-system   coredns-657694c6f4-fdz4f   1/1     Running       0          5m12s
kube-system   coredns-657694c6f4-kvm92   1/1     Running       0          5m12s
kube-system   kube-proxy-plwlc           1/1     Running       0          6m5s
```

5. Inspect one of the `aws-node-*` (AWS VPC CNI) pods to ensure prefix delegation is enabled and warm prefix target is 1:

```sh
kubectl describe pod aws-node-77rwz -n kube-system

# Output should look like below (truncated for brevity)
  Environment:
    ADDITIONAL_ENI_TAGS:                    {}
    AWS_VPC_CNI_NODE_PORT_SUPPORT:          true
    AWS_VPC_ENI_MTU:                        9001
    AWS_VPC_K8S_CNI_CONFIGURE_RPFILTER:     false
    AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG:     false
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
terraform destroy -auto-approve
```
