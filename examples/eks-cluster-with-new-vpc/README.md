# EKS Cluster Deployment with new VPC

This example deploys the following Basic EKS Cluster with VPC

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with one managed node group and fargate profile

## How to Deploy

### Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step 1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step 2: Run Terraform INIT

Initialize a working directory with configuration files

```shell script
cd examples/eks-cluster-with-new-vpc/
terraform init
```

#### Step 3: Run Terraform PLAN

Verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 4: Finally, Terraform APPLY

Deploy VPC, EKS cluster with Node groups and Kubernetes Add-ons with `--target` option

```sh
terraform apply -target="module.aws_vpc" 
terraform apply -target="module.eks_blueprints"
terraform apply -target="module.eks_blueprints_kubernetes_addons"
```

Finally run the below command for additional resources that are  not in the above modules

```sh
terraform apply 
```

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step 5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step 6: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step 7: List all the pods running in `kube-system` namespace

    $ kubectl get pods -n kube-system

## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons"
terraform destroy -target="module.eks_blueprints"
terraform destroy -target="module.aws_vpc"
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy 
```
