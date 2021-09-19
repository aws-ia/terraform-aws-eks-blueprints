# Windows Support

This example shows how to enable Windows support in the EKS cluster. 

## Pre-requisites

[eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) is currently needed to enable Windows support.

## Required input

As of the time of writing of this document, Windows workloads cannot be deployed on AWS-managed nodes or Fargate profiles. Self-managed nodes must be deployed for Windows workloads. This can be done using the following variables, as shown in the `eks-with-windows-support.tfvars` file:
```
# Enable self-managed nodegroup in the EKS cluster.
enable_self_managed_nodegroups = true
# Enable Windows support.
enable_windows_support = true
# Windows self-managed nodegroup example. 
# Other Linux and Windows self-managed nodegroups can
# be added in the same self_managed_node_groups map.
self_managed_node_groups = {
  ...
  ...
  #---------------------------------------------------------#
  # ON-DEMAND Self Managed Windows Worker Node Group
  #---------------------------------------------------------#
  windows_ondemand = {
    node_group_name = "windows-ondemand" # Name is used to create a dedicated IAM role for each node group and adds to AWS-AUTH config map
    custom_ami_type = "windows"          # amazonlinux2eks  or bottlerocket or windows
    # custom_ami_id   = "ami-xxxxxxxxxx" # Uncomment to bring your own custom AMI. Default Windows AMI is the latest EKS Optimized Windows Server 2019 English Core AMI.
    public_ip       = false              # Enable only for public subnets

    disk_size     = 50
    instance_type = "m5.large"

    desired_size = 2
    max_size     = 4
    min_size     = 2

    k8s_labels = {
      Environment = "preprod"
      Zone        = "sbx"
      WorkerType  = "WINDOWS_ON_DEMAND"
    }

    additional_tags = {
      ExtraTag    = "windows-on-demand"
      Name        = "windows-on-demand"
      subnet_type = "private"
    }

    subnet_type = "private" # private or public
    subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

    create_worker_security_group = true # Creates a dedicated sec group for this Node Group
  }
  ...
  ...
}
```

By default, the latest EKS-optimized Windows 2019 Server Core AMI will be used. You can provide a custom AMI in the `self_managed_node_groups` map element as follows:
```
    custom_ami_id = "ami-12345678901234567"
```

Windows nodes user data script template is in `aws-eks-self-managed-node-groups/templates/userdata-windows.tpl`. It takes the following parameters:
* cluster_name - The cluster's name
* cluster_ca_base64 - The cluster's base64-encoded certifying authority data. Currently not used for Windows.
* cluster_endpoint - The cluster's K8s API server endpoint. Currently not used for Windows.
* pre_userdata - Powershell script snippet to be executed before running the main user data script
* post_userdata - Powershell script snippet to be executed after running the main user data script
* bootstrap_extra_args - Extra arguments for the bootstrap script (where applicable). Currently not used for Windows.
* kubelet_extra_args - Extra arguments for kubelet

## Node selection for pods

Ensure that all pods / deployments / Helm chart values use either [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) or [Node affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity) to get assigned to either Windows or Linux nodes. The node label `kubernetes.io/os` can be used to select appropriate Windows or Linux nodes. See [Windows](./k8s/windows-iis-aspnet.yaml) and [Linux](./k8s/linux-nginx.yaml) examples included here.

## Deployment & Testing

* Deploy the EKS cluster using the input variables as in `eks-with-windows-support.tfvars`, by following the [deployment steps](../../README.md#deployment-steps). 
* Verify Windows support in the cluster using a sample Windows pod deployment:
```bash
kubectl apply -f examples/windows-support/k8s/windows-iis-aspnet.yaml
```
* Verify a Linux sample pod deployment:
```bash
kubectl apply -f examples/windows-support/k8s/linux-nginx.yaml
```

## See also

* [Windows support considerations](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html)
