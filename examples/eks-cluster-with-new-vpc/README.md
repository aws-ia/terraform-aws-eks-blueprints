# EKS Cluster Deployment with new VPC
This example deploys the following Basic EKS Cluster with VPC
 - Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
 - Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
 - Creates EKS Cluster Control plane with one managed node group and fargate profile

## How to Deploy
### Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply
1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
3. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps
#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step2: Run Terraform INIT
Initialize a working directory with configuration files

```shell script
cd examples/eks-cluster-with-new-vpc/
terraform init
```

#### Step3: Run Terraform PLAN
Verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step4: Finally, Terraform APPLY
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

## How to Destroy
The following command destroys the resources created by `terraform apply`

```shell script
cd examples/eks-cluster-with-new-vpc
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
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws | v3.2.0 |
| <a name="module_eks_blueprints"></a> [eks\_blueprints](#module\_eks\_blueprints) | ../.. | n/a |
| <a name="module_kubernetes_addons"></a> [kubernetes\_addons](#module\_kubernetes\_addons) | ../../modules/kubernetes-addons | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes Version | `string` | `"1.21"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | `"preprod"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | `"aws"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | n/a |
| <a name="output_eks_managed_nodegroup_arns"></a> [eks\_managed\_nodegroup\_arns](#output\_eks\_managed\_nodegroup\_arns) | Managed Node group id |
| <a name="output_eks_managed_nodegroup_ids"></a> [eks\_managed\_nodegroup\_ids](#output\_eks\_managed\_nodegroup\_ids) | Managed Node group id |
| <a name="output_eks_managed_nodegroup_role_name"></a> [eks\_managed\_nodegroup\_role\_name](#output\_eks\_managed\_nodegroup\_role\_name) | Managed Node group role name |
| <a name="output_eks_managed_nodegroup_status"></a> [eks\_managed\_nodegroup\_status](#output\_eks\_managed\_nodegroup\_status) | Managed Node group status |
| <a name="output_eks_managed_nodegroups"></a> [eks\_managed\_nodegroups](#output\_eks\_managed\_nodegroups) | Managed Node group name |
| <a name="output_region"></a> [region](#output\_region) | AWS region |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | n/a |
| <a name="output_vpc_private_subnet_cidr"></a> [vpc\_private\_subnet\_cidr](#output\_vpc\_private\_subnet\_cidr) | n/a |
| <a name="output_vpc_public_subnet_cidr"></a> [vpc\_public\_subnet\_cidr](#output\_vpc\_public\_subnet\_cidr) | n/a |

<!--- END_TF_DOCS --->
