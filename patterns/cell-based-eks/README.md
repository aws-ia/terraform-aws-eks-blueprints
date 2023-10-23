# Cell-Based Architecture for Amazon EKS

This pattern demonstrates how to configure a cell-based architecture for Amazon Elastic Kubernetes Service (Amazon EKS). It moves away from typical multiple Availability Zone (AZ) clusters to a single Availability Zone cluster. These single AZ clusters are called cells, and the aggregation of these cells in each Region is called a supercell. These cells help to ensure that a failure in one cell doesn't affect the cells in another, reducing data transfer costs and improving both the availability and resiliency against AZ wide failures for Amazon EKS workloads.

Refer to the [AWS Solution Guidance](https://aws.amazon.com/solutions/guidance/cell-based-architecture-for-amazon-eks/) for more details.

## Notable configuration

* This sample rely on reading data from Terraform Remote State in the different folders. In a production setup, Terraform Remote State is stored in a persistent backend such as Terraform Cloud or S3. For more information, please refer to the Terraform [Backends](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) documentation

## Folder structure

### [`0.vpc`](0.vpc/)

This folder creates the VPC for all clusters. In this demonstration we are creating 2 cells sharing the same VPC. So, the VPC creation is not part of the cluster provisionig and therefore lives in a seperate folder. You could also explore a VPC per cluster depending on your needs.

### [`1.cell1`](1.cell1/)

This folder creates an Amazon EKS Cluster, named by default `cell-1` (see [`variables.tf`](1.cell1/variables.tf)), with AWS Load Balancer Controller, and Karpenter installation.
Configurations in this folder to be aware of:

* The cluster is configured to use the subnet-1 (AZ-1) created in the `0.vpc` folder.
* Karpenter `Provisioner` and `AWSNodeTemplate` resources are pointing to AZ-1 subnet.
* Essential operational addons like `coredns`, `aws-load-balancer-controller`, and `karpenter` are deployed to Fargate configured with AZ-1 subnet.

### [`2.cell2`](2.cell2/)

Same configuration as in `1.cell1` except the name of the cluster is `cell-2` and deployed in `az-2`

### [`3.test-setup`](3.test-setup/)

This folder test the installation setup. It does by scaling the sample `inflate` application replicas and watch for Karpenter to launch EKS worker nodes in respective AZs.

## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

### Step 0 - Create the VPC

```shell
cd 0.vpc
terraform init
terraform apply -auto-approve
cd..
```

### Step 1 - Deploy cell-1

```shell
cd 1.cell1
terraform init
terraform apply -auto-approve
cd..
```

### Step 2 - Deploy cell-2

```shell
cd 2.cell2
terraform init
terraform apply -auto-approve
cd..
```

### Step 3 - test installation

```shell
cd 3.test-setup
./test_setup.sh
cd..
```

This script scale the sample application `inflate` to 20 replicas in both cells. As replica pods go into pending state due to insufficient compute capacity, Karpenter will kick-in and bring up the EC2 worker nodes in respective AZs.

## Destroy

To teardown and remove the resources created in this example:

```shell
cd 2.cell2
terraform apply -destroy -auto-approve
cd ../1.cell1
terraform apply -destroy -auto-approve
cd ../0.vpc
terraform apply -destroy -auto-approve
```
