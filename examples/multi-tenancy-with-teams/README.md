# EKS Cluster with Teams to a new VPC

This example deploys a new EKS Cluster with Teams to a new VPC.

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates an Internet gateway for the Public Subnets and a NAT Gateway for the Private Subnets
- Creates an EKS Cluster Control plane with public endpoint with one managed node group
- Creates two application teams - blue and red and deploys team manifests to the cluster
- Creates a single platform admin team - you will need to provide your own IAM user/role first, see the example for more details

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

#### Step2: Run `terraform init`
to initialize a working directory with configuration files

```shell script
cd examples/multi-tenancy-with-teams/
terraform init
```

#### Step3: Run `terraform plan`
to verify the resources created by this execution

```shell script
export AWS_REGION=<enter-your-region>   # Select your own region
terraform plan
```

#### Step4: Finally, `terraform apply`
to create resources

```shell script
terraform apply
```

Enter `yes` to apply

### Configure kubectl and test cluster
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step5: Run update-kubeconfig command.

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step6: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step7: List all the pods running in kube-system namespace

    $ kubectl get pods -n kube-system

## How to Destroy
```shell script
cd examples/multi-tenancy-with-teams
terraform destroy
```

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.66.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.7.0 |
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

| Name | Description |
|------|-------------|
| <a name="output_ssp_output"></a> [ssp\_output](#output\_ssp\_output) | SSP module outputs |

<!--- END_TF_DOCS --->
