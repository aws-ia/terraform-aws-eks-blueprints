# Getting Started

This getting started guide will help you deploy your first EKS environment using the `terraform-ssp-amazon-eks` module.

## Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
3. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deployment Steps

The following steps will walk you through the deployment of an example [DEV cluster](../deploy/eks-cluster-with-new-vpc/main.tf) configuration.
This configuration will deploy a private EKS cluster with public and private subnets.
One managed node group and a Fargate profile for the default namespace will be placed in private subnets. The ALB created by the AWS LB Ingress controller will be placed in Public subnets. The example will also deploy the following Kubernetes add-ons

✅  AWS LB Ingress Controller\
✅  Metrics Server\
✅  Cluster Autoscaler

### Clone the repo

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

### Run Terraform INIT

CD into the sample directory.

```shell script
cd deploy/eks-cluster-with-new-vpc/
```

Initialize the working directory with configuration files.

```shell script
terraform init
```

### Run Terraform PLAN

Verify the resources that will be created by this execution.

```shell script
terraform plan
```

### Finally, Terraform APPLY

Deploy your EKS environment.

```shell script
terraform apply
```

### Configure kubectl and test cluster

Details for your EKS Cluster can be extracted from terraform output or from AWS Console to get the name of cluster.

This following command used to update the `kubeconfig` in your local machine where you run `kubectl` commands to interact with your EKS Cluster.

```
$ aws eks --region <region> update-kubeconfig --name <cluster-name>
```

## Validation

### List all the worker nodes by running the command below

```
$ kubectl get nodes
```

### List all the pods running in kube-system namespace

```
$ kubectl get pods -n kube-system
```
