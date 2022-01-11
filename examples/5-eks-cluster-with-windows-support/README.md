# EKS Cluster with Windows support

This example deploys the following AWS resources.
 - A new VPC, 3 AZs with private and public subnets
 - Necessary VPC endpoints for node groups in private subnets
 - An Internet gateway for the VPC and a NAT gateway in each public subnet
 - An EKS cluster with an AWS-managed node group of spot Linux worker nodes and a self-managed node group of on-demand Windows worker nodes

The following steps walk you through the deployment of this example.

# How to deploy

## Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run `terraform plan` and `terraform apply`

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deployment steps

### Step1: Clone the repo using the command below

```bash
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

### Step2: Run terraform init

to initialize a working directory with configuration files

```bash
cd examples/5-eks-cluster-with-windows-support
terraform init
```

### Step3: Run terraform plan

to verify the resources created by this execution

```bash
export AWS_REGION=us-east-1   # Select your own region
terraform plan
```

### Step4: Run terraform apply

to create resources

```bash
terraform apply -auto-approve
```

## Configure kubectl and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

### Step5: Run update-kubeconfig command.

`~/.kube/config` file gets updated with EKS cluster context from the below command. Use the cluster's name available in the Terraform output as `eks_cluster_name`.

    $ aws eks --region us-east-1 update-kubeconfig --name <eks_cluster_name>

### Step6: (Optional) Deploy sample Windows and Linux workloads to verify support for both operating systems

When Windows support is enabled in the cluster, it is necessary to use one of the ways to assign pods to specific nodes, such as `nodeSelector` or `affinity`. See the [K8s documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) for more info. This example uses `nodeSelector`s to select nodes with appropriate OS for pods.

#### Sample Windows deployment
```bash
cd examples/5-eks-cluster-with-windows-support
# Sample Windows deployment
kubectl apply -f ./k8s/windows-iis-aspnet.yaml
# Wait for the Windows pod status to change to Running
# On Mac, install the watch command using brew install watch
watch -n 1 "kubectl get po -n windows"
# When the pod starts running, forward the service port
kubectl port-forward -n windows service/aspnet 8000:80
```
Now visit [http://localhost:8000/demo](http://localhost:8000/demo) in your browser. If everything went well, the page should display text "Hello, World!". Use Ctrl+C in your terminal to stop the `kubectl` port forwarding.

#### Sample Linux deployment
```bash
# Sample Linux deployment
kubectl apply -f ./k8s/linux-nginx.yaml
```

# Cleanup

```bash
cd examples/5-eks-cluster-with-windows-support
# If you deployed sample Windows & Linux workloads from Step6
kubectl delete svc,deploy -n windows --all
kubectl delete svc,deploy -n linux --all
# Destroy all resources
terraform destroy -auto-approve
```

# See also

* [EKS Windows support considerations](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html)

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.66.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.6.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.66.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-eks-accelerator-for-terraform"></a> [aws-eks-accelerator-for-terraform](#module\_aws-eks-accelerator-for-terraform) | ../.. | n/a |
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws | v3.2.0 |
| <a name="module_kubernetes-addons"></a> [kubernetes-addons](#module\_kubernetes-addons) | ../../modules/kubernetes-addons | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

No inputs.

## Outputs

No outputs.

<!--- END_TF_DOCS --->
