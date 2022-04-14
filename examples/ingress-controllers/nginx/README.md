# EKS Cluster Deployment with the nginx add-on enabled

This example deploys the following Basic EKS Cluster with VPC. In AWS we use a Network load balancer (NLB) to expose the NGINX Ingress controller behind a Service of _Type=LoadBalancer_ leveraging AWS Load Balancer Controller (LBC).

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with managed nodes
- Creates the nginx controller resources; such as an internet facing AWS Network Load Balancer, AWS IAM role and policy
  for the nginx service account, etc.
  - Nginx controller service is using the LBC annotations to manage the NLB.

## How to Deploy

### Prerequisites

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step2: Run Terraform INIT

Initialize a working directory with configuration files

```shell script
cd examples/ingress-controllers/nginx
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
terraform apply -target="module.aws_vpc"
terraform apply -target="module.module.eks-blueprints"
terraform apply -target="module.module.eks-blueprints-kubernetes-addons"
terraform apply -target="module.module.aws_load_balancer_controller" 
terraform apply -target="module.module.ingress_nginx" 
```

Enter `yes` for each apply

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

``` shell
    aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>
```

#### Step6: List all the worker nodes by running the command below

``` shell
    kubectl get nodes
```

#### Step7: List all the pods running in `nginx` namespace

``` shell
    kubectl get pods -n nginx
```

## How to Destroy

The following command destroys the resources created by `terraform apply`

```shell script
cd examples/ingress-controllers/nginx
terraform apply -target="module.module.ingress_nginx" -auto-approve
terraform apply -target="module.module.aws_load_balancer_controller" -auto-approve
terraform apply -target="module.module.eks-blueprints-kubernetes-addons" -auto-approve
terraform apply -target="module.module.eks-blueprints" -auto-approve
terraform apply -target="module.aws_vpc" -auto-approve
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
| <a name="module_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#module\_aws\_load\_balancer\_controller) | ../../../modules/kubernetes-addons | n/a |
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws | v3.2.0 |
| <a name="module_eks-blueprints"></a> [eks-blueprints](#module\_eks-blueprints) | ../../.. | n/a |
| <a name="module_eks-blueprints-kubernetes-addons"></a> [eks-blueprints-kubernetes-addons](#module\_eks-blueprints-kubernetes-addons) | ../../../modules/kubernetes-addons | n/a |
| <a name="module_ingress_nginx"></a> [ingress\_nginx](#module\_ingress\_nginx) | ../../../modules/kubernetes-addons | n/a |

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
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes Version | `string` | `"1.21"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | `"preprod"` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | `"aws001"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |

<!--- END_TF_DOCS --->

## Learn more

Read more about using NLB to expose the NGINX ingress controller using AWS Load Balancer Controller [here](https://kubernetes.github.io/ingress-nginx/deploy/#aws).