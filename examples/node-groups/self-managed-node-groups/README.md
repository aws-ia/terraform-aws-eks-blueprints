# EKS Cluster with Self-managed Node Group

This example deploys a new EKS Cluster with a [self-managed node group](https://docs.aws.amazon.com/eks/latest/userguide/worker.html) into a new VPC.

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates an Internet gateway for the Public Subnets and a NAT Gateway for the Private Subnets
- Creates an EKS Cluster Control plane with a self-managed node group

## How to Deploy

### Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step 1: Clone the repo using the command below

```sh
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

#### Step 2: Run Terraform INIT

Initialize a working directory with configuration files

```sh
cd examples/node-groups/self-managed-node-groups/
terraform init
```

#### Step 3: Run Terraform PLAN

Verify the resources created by this execution

```sh
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 4: Finally, Terraform APPLY

to create resources

```sh
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

#### Step 7: List all the pods running in `kube-system` namespace

    $ kubectl get pods -n kube-system

#### Step 8: List the auto scaling group created for the self-managed node group

    $ aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names aws001-preprod-dev-eks-self-managed-ondemand

## How to Destroy

The following command destroys the resources created by `terraform apply`

```sh
cd examples/node-groups/self-managed-node-groups
terraform destroy --auto-approve
```
