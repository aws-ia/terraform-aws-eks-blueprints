# Fully Private EKS Cluster with VPC and VPC Endpoints deployment

This example deploys a fully private EKS Cluster into a new VPC.
 - Creates a new VPC and 3 Private Subnets
 - VPC Endpoints for various services and S3 VPC Endpoint gateway
 - Creates EKS Cluster Control plane with a private endpoint and with one Managed node group

Please see this [document](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html) for more details on configuring fully private EKS Clusters

Here is the high level design of the solution. The solution has been split into 3 different TerraForm stacks for simplicity.
1. VPC
2. EKS
3. ADD-ONS

![High Level Design](./images/EKS_private_cluster.jpg)

## How to Deploy
### Prerequisites:


### Environment Set up.

Pre-requisites
1. This examples assumes that you have a default VPC in your AWS account.
2. An EC2 instance running in the default VPC that is running Jekins OR having the pre-requisite tools mentioned below. For simplicity this EC2 instance is running in the public VPC.

    2.1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

    2.2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)

    2.3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

3. You can SSH into the EC2 instance to run Terraform commands OR access the Jenkins server running on this EC2 instance. Please note that setting up Jenkins on the EC2 instance is out of scope from this example.
4. Deploy the individual stacks from each of the sub folders. i.e.

    4.1 VPC

    4.2 EKS

    4.3 Add-ons


Please refer to the README.MD in the individual sub folders for the deployment instructions.

<!--- END_TF_DOCS --->
