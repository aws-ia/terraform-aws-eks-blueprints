# TLS with AWS PCA Issuer

This example deploys the following

- Basic EKS Cluster with VPC
- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Enables cert-manager module
- Enables aws-privateca-issuer module
- Creates AWS Certificate Manager Private Certificate Authority, enables and activates it
- Creates the CRDs to fetch `tls.crt`, `tls.key` and `ca.crt` , which will be available as Kubernetes Secret. Now you may mount the secret in the application for end to end TLS.

## How to Deploy

### Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step 1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

#### Step 2: Run Terraform INIT

Initialize a working directory with configuration files

```shell script
cd examples/tls-with-aws-pca-issuer/
terraform init
```

#### Step 3: Run Terraform PLAN

Verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 4: Finally, Terraform APPLY

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

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step 6: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step 7: List all the pods running in `aws-privateca-issuer` and `cert-manager` namespace

    $ kubectl get pods -n aws-privateca-issuer
    $ kubectl get pods -n cert-manager

#### Step 8: View the `Certificate` status. It should be in 'Ready' state.

    $ kubectl get Certificate

## How to Destroy

The following command destroys the resources created by `terraform apply`

```shell script
cd examples/tls-with-aws-pca-issuer
terraform destroy --auto-approve
```
