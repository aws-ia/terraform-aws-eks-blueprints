# EKS Cluster with Fargate Profiles

This example deploys a new EKS Cluster into a new VPC and crates a Fargate profile.

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates an Internet gateway for the Public Subnets and a NAT Gateway for the Private Subnets
- Creates an EKS Cluster Control plane with one Fargate profile

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
cd examples/node-groups/fargate-profiles/
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

#### Step 6: Create a simple pod with respective match labels.

    $ kubectl run test-pod --image=nginx --labels="Zone=dev,Environment=preprod,env=fargate"

#### Step 7: List all the nodes by running the command below and verify the fargate nodes

    $ kubectl get nodes

#### Step 8: List all the pods running in `kube-system` namespace

    $ kubectl get pods -n kube-system

Note : CoreDNS requires [additional setup](https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html) if customers use only Fargate

## How to Destroy

The following command destroys the resources created by `terraform apply`

```sh
cd examples/node-groups/fargate-profiles
terraform destroy --auto-approve
```
