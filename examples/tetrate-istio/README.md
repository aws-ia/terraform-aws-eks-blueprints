# EKS Cluster Deployment with the Tetrate Istio add-on enabled

This example deploys the following Basic EKS Cluster with VPC:

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with managed nodes

## How to Deploy

### Prerequisites

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
```

#### Step2: Run Terraform INIT

Initialize a working directory with configuration files

```shell script
cd examples/tetrate-istio
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
terraform apply
```

Enter `yes` to apply

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

```shell script
aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>
```

#### Step6: List all the pods running in `istio-system` namespace

```shell script
kubectl get pods -n istio-system
```

#### Step7: Deploy Bookinfo example

[Deploy](https://istio.io/latest/docs/examples/bookinfo/) `Bookinfo` example application.

## How to Destroy

The following command destroys the resources created by `terraform apply`

```shell script
cd examples/tetrate-istio
terraform destroy --auto-approve
```

<!--- BEGIN_TF_DOCS --->
<!--- END_TF_DOCS --->

## Learn more

Learn more about [Tetrate Istio Distro](https://istio.tetratelabs.io/).
