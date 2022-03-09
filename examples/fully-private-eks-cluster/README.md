# Fully Private EKS Cluster with VPC and Endpoints deployment

This example deploys a fully private EKS Cluster into a new VPC.
 - Creates a new VPC and 3 Private Subnets
 - VPC Endpoints for various services and S3 VPC Endpoint gateway
 - Creates EKS Cluster Control plane with one Managed node group
    - EKS Cluster API endpoint that can be set to public and private, and then into private only.

Please see this [document](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html) for more details on configuring fully private EKS Clusters

## How to Deploy
### Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply
1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
3. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps
#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

#### Step2: Run Terraform INIT
Initialize a working directory with configuration files

```shell script
cd examples/fully-private-eks-cluster/
terraform init
```

#### Step3: Run Terraform PLAN
Verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step4: Terraform APPLY
to create resources

```shell script
terraform apply
```

Enter `yes` to apply

### Configure `kubectl` and test cluster
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step6: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step7: List all the pods running in `kube-system` namespace

    $ kubectl get pods -n kube-system

### Setting up private only API endpoint and accessing the cluster

- To set the API endpoint to private only, on the `main.tf` file under the SSP module:
    - Set `eks_cluster_api_endpoint_public = false`
    - Set `eks_cluster_api_endpoint_private = true`

- To access the private cluster, you need to access it from a machine that can access the VPC and the private subnets. Few ways to do this are:
    - Create a bastion host in the VPC and then access the cluster from the bastion host
    - Create a cloud9 instance in the VPC and then access the cluster from the cloud9 instance
These examples assume you do not have any other network infrastructure in place (e.g. direct connect(DX), VPN etc.).

Learn more about private EKS clusters [here](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html)

## How to Destroy
The following command destroys the resources created by `terraform apply`

```shell script
cd examples/fully-private-eks-cluster
terraform destroy --auto-approve
```

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
| <a name="module_vpc_endpoint_gateway"></a> [vpc\_endpoint\_gateway](#module\_vpc\_endpoint\_gateway) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | v3.2.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | v3.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |

## Inputs

No inputs.

## Outputs

No outputs.

<!--- END_TF_DOCS --->
