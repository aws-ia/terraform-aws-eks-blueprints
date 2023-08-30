# Amazon EKS Multi-Cluster w/ Istio

This example shows how to provision 2 Amazon EKS clusters with Istio setup on each of them.
The Istio will be set-up to operate in a [Multi-Primary](https://istio.io/latest/docs/setup/install/multicluster/multi-primary/) way where services are shared across clusters.

* Deploy a VPC with additional security groups to allow cross-cluster communication and communication from nodes to the other cluster API Server endpoint
* Deploy 2 EKS Cluster with one managed node group in an VPC
* Add node_security_group rules for port access required for Istio communication
* Install Istio using Helm resources in Terraform
* Install Istio Ingress Gateway using Helm resources in Terraform
* Deploy/Validate Istio communication using sample application

Refer to the [documentation](https://istio.io/latest/docs/concepts/) for `Istio` concepts.

## Notable configuration

* This sample rely on reading data from Terraform Remote State in the different folders. In a production setup, Terraform Remote State is stored in a persistent backend such as Terraform Cloud or S3. For more information, please refer to the Terraform [Backends](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) documentation
* The process for connecting clusters is seperated from the cluster creation as it requires all cluster to be created first, and excahnge configuration between one to the other

## Folder structure

### [`0.certs-tool`](0.certs-tool/)

This folder is the [Makefiles](https://github.com/istio/istio/tree/master/tools/certs) from the Istio projects to generate 1 root CA with 2 intermediate CAs for each cluster. Please refer to the ["Certificate Management"](https://istio.io/latest/docs/tasks/security/cert-management/) section in the Istio documentation. For production setup it's [highly recommended](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/#plug-in-certificates-and-key-into-the-cluster) by the Istio project to have a production-ready CA solution.

> **_NOTE:_**  The [0.certs-tool/create-certs.sh](0.certs-tool/create-certs.sh) script needs to run before the cluster creation so the code will pick up the relevant certificates

### [`0.vpc`](0.vpc/)

This folder creates the VPC for both clusters. The VPC creation is not part of the cluster provisionig and therefore lives in a seperate folder.
To support the multi-cluster/Multi-Primary setup, this folder also creates additional security group to be used by each cluster worker nodes to allow cross-cluster communication (resources `cluster1_additional_sg` and `cluster2_additional_sg`). These security groups allow communication from one to the other and each will be added to the worker nodes of the relevant cluster

### [`1.cluster1`](1.cluster1/)

This folder creates an Amazon EKS Cluster, named by default `cluster-1` (see [`variables.tf`](1.cluster1/variables.tf)), with AWS Load Balancer Controller, and Istio installation.
Configurations in this folder to be aware of:

* The cluster is configured to use the security groups created in the `0.vpc` folder (`cluster1_additional_sg` in this case).
* Kubernetes Secret named `cacerts` is created with the certificates created by the [0.certs-tool/create-certs.sh](0.certs-tool/create-certs.sh) script
* Kubernetes Secret named `cacerts` named `istio-reader-service-account-istio-remote-secret-token` of type `Service-Account` is being created. This is to replicate the [istioctl experimental create-remote-secret](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-experimental-create-remote-secret) command. This secret will be used in folder [`3.istio-multi-primary`](3.istio-multi-primary/) to apply kubeconfig secret with tokens from the other cluster to be abble to communicate to the other cluster API Server

### [`2.cluster2`](2.cluster2/)

Same configuration as in `1.cluster1` except the name of the cluster which is `cluster-2`.

### [`3.istio-multi-primary`](3.istio-multi-primary/)

This folder deploys a reader secret on each cluster. It replicates the [`istioctl experimental create-remote-secret`](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-experimental-create-remote-secret) by applying a kubeconfig secret prefixed `istio-remote-secret-` with the cluster name at the end.

### [`4.test-connectivity`](4.test-connectivity/)

This folder test the installation connectivity. It follows the Istio guide [Verify the installation](https://istio.io/latest/docs/setup/install/multicluster/verify/) by deploying services on each cluster, and `curl`-ing from one to the other

## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

### Prereq - Provision Certificates

```shell
cd 0.certs-tool
./create-certs.sh
cd..
```

### Step 0 - Create the VPC

```shell
cd 0.certs-tool
./create-certs.sh
cd..
```

### Step 1 - Deploy cluster-1

```shell
cd 1.cluster1
terraform init
terraform apply -auto-approve
cd..
```

### Step 2 - Deploy cluster-2

```shell
cd 2.cluster2
terraform init
terraform apply -auto-approve
cd..
```

### Step 3 - Configure Istio Multi-Primary

```shell
cd 3.istio-multi-primary
terraform init
terraform apply -auto-approve
cd..
```

### Step 4 - test installation and connectivity

```shell
cd 4.test-connectivity
./test_connectivity.sh
cd..
```

This script deploy the sample application to both clusters and run curl from a pod in one cluster to a service that is deployed in both cluster. You should expect to see responses from both `V1` and `V2` of the sample application.
The script run 4 `curl` command from cluster-1 to cluster-2 and vice versa

## Destroy

To teardown and remove the resources created in this example:

```shell
cd 3.istio-multi-primary
terraform apply -destroy -autoapprove
cd ../2.cluster2
terraform apply -destroy -autoapprove
cd ../1.cluster1
terraform apply -destroy -autoapprove
cd ../0.vpc
terraform apply -destroy -autoapprove
```
