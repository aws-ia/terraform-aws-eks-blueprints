# EKS Cluster with Managed Node Group

This example deploys a new EKS Cluster with a Managed node group into a new VPC.

* Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
* Creates an Internet gateway for the Public Subnets and a NAT Gateway for the
  Private Subnets
* Creates an EKS Cluster Control plane with Managed node groups

## How to Deploy

### Prerequisites

Ensure that you have installed the following tools in your Mac or Windows Laptop
before start working with this module and run Terraform Plan and Apply

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
* [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

#### Step2: Run Terraform INIT

Initialize a working directory with configuration files

```shell script
cd examples/node-groups/managed-node-groups-tfvars/
terraform init
```

#### Step3: Run Terraform PLAN

Verify the resources created by this execution

```shell script
export AWS_REGION=eu-central-1   # Select your own region
terraform plan -var-file="variables.tfvars"
```

#### Step4: Finally, Terraform APPLY

to create resources

```shell script
terraform apply
```

Enter `yes` to apply

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console
to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine
where you run kubectl commands to interact with your EKS Cluster.

#### Step5: Run `update-kubeconfig` command

Get the list of your clusters

```shell script
aws eks --region "${AWS_REGION}" list-clusters
```

`~/.kube/config` file gets updated with cluster details and certificate from
the below command

```shell script
aws eks --region "${AWS_REGION}" update-kubeconfig --name "aws-preprod-dev-eks"
```

#### Step6: List all the worker nodes by running the command below

```shell script
kubectl get nodes
```

#### Step7: List all the pods running in `kube-system` namespace

```shell script
kubectl get pods -n kube-system
```

## How to Destroy

The following command destroys the resources created by `terraform apply`

```shell script
cd examples/node-groups/managed-node-groups-tfvars
terraform destroy --auto-approve
```

---

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.6.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-eks-accelerator-for-terraform"></a> [aws-eks-accelerator-for-terraform](#module\_aws-eks-accelerator-for-terraform) | ../../.. | n/a |
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws | v3.12.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | `"preprod"` | no |
| <a name="input_managed_node_groups"></a> [managed\_node\_groups](#input\_managed\_node\_groups) | A map of Managed node group(s) | `any` | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | `"aws"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | `"dev"` | no |

## Outputs

No outputs.

<!--- END_TF_DOCS --->
