# Fully Private EKS Cluster with VPC and VPC Endpoints deployment

This example deploys a fully private EKS Cluster into a new VPC.
<<<<<<< HEAD
 - Creates a new VPC and 3 Public and Private Subnets
 - VPC Endpoints for various services and S3 VPC Endpoint gateway
 - Creates EKS Cluster Control plane with a private endpoint and with one Managed node group

Please see this [document](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html) for more details on configuring fully private EKS Clusters

Here is the high level design of the solution. The solution has been split into 3 different Terraform stacks for simplicity.
1. VPC
2. EKS
3. ADD-ONS
=======

- Creates a new VPC and 3 Private Subnets
- VPC Endpoints for various services and S3 VPC Endpoint gateway
- Creates EKS Cluster Control plane with one Managed node group
  - EKS Cluster API endpoint that can be set to public and private, and then into private only.

Please see this [document](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html) for more details on configuring fully private EKS Clusters

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
cd examples/fully-private-eks-cluster/
terraform init
```

#### Step 3: Run Terraform PLAN

Verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 4: Terraform APPLY

to create resources

```shell script
terraform apply
```

Enter `yes` to apply

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step 5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command
>>>>>>> upstream/main

![High Level Design](../../images/EKS_private_cluster.jpg)

<<<<<<< HEAD
## How to Deploy
### Prerequisites:
1. This examples assumes that you have a default VPC in your AWS account.
2. An EC2 instance running in the default VPC that is running Jekins OR having the pre-requisite tools mentioned below. This EC2 instance can be used as a Jenkins Server OR as a bastion host. For simplicity this EC2 instance is running in the public subnet of this default VPC.
3. The following tools are installed on the EC2 instance.

    3.1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

    3.2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)

    3.3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Environment Set up.

3. You can SSH into the EC2 instance to run Terraform commands OR access the Jenkins server running on this EC2 instance to run a jenkins pipeline that can run the below Terraform stack(s). Please note that setting up Jenkins on the EC2 instance is out of scope from this example.

4. Deploy the individual stacks from each of the sub folders. i.e.

    4.1 VPC - Please refer to the [instructions](./vpc/README.md) to deploy a new VPC. 

    4.2 EKS - Please refer to the [instructions](./eks/README.md) to deploy a private EKS cluster.

    4.3 Add-ons - Please refer to the [instructions](./add-ons/README.md) to deploy the add-ons to the private EKS cluster using GitOps.

<!--- END_TF_DOCS --->
=======
#### Step 6: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step 7: List all the pods running in `kube-system` namespace

    $ kubectl get pods -n kube-system

### Setting up private only API endpoint and accessing the cluster

- To set the API endpoint to private only, on the `main.tf` file under the EKS Blueprints module:

  - Set `eks_cluster_api_endpoint_public = false`
  - Set `eks_cluster_api_endpoint_private = true`

- To access the private cluster, you need to access it from a machine that can access the VPC and the private subnets. Few ways to do this are: - Create a bastion host in the VPC and then access the cluster from the bastion host - Create a cloud9 instance in the VPC and then access the cluster from the cloud9 instance
  These examples assume you do not have any other network infrastructure in place (e.g. direct connect(DX), VPN etc.).

Learn more about private EKS clusters [here](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html)

## How to Destroy

The following command destroys the resources created by `terraform apply`

```shell script
cd examples/fully-private-eks-cluster
terraform destroy --auto-approve
```
>>>>>>> upstream/main
