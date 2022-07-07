# EKS Cluster Deployment with the nginx add-on enabled

This example deploys the following Basic EKS Cluster with VPC. In AWS we use a Network load balancer (NLB) to expose the NGINX Ingress controller behind a Service of _Type=LoadBalancer_ leveraging AWS Load Balancer Controller (LBC).

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with managed nodes
- Creates the nginx controller resources; such as an internet facing AWS Network Load Balancer, AWS IAM role and policy
  for the nginx service account, etc.
  - Nginx controller service is using the LBC annotations to manage the NLB.

## How to Deploy

### Prerequisites

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
cd examples/ingress-controllers/nginx
terraform init
```

#### Step 3: Run Terraform PLAN

Verify the resources created by this execution

```sh
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 4: Finally, Terraform APPLY

**Deploy the pattern**

```sh
terraform apply
```

Enter `yes` to apply.

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step 5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

```sh
    aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>
```

#### Step 6: List all the worker nodes by running the command below

```sh
    kubectl get nodes
```

#### Step 7: List all the pods running in `nginx` namespace

```sh
    kubectl get pods -n nginx
```

## How to Destroy

The following command destroys the resources created by `terraform apply`

```sh
cd examples/ingress-controllers/nginx
terraform destroy -target="module.eks_blueprints_kubernetes_addons.module.ingress_nginx[0]" -auto-approve
terraform destroy -target="module.eks_blueprints_kubernetes_addons.module.aws_load_balancer_controller[0]" -auto-approve
terraform destroy -target="module.eks-blueprints-kubernetes-addons" -auto-approve
terraform destroy -target="module.eks-blueprints" -auto-approve
terraform destroy -auto-approve
```

## Learn more

Read more about using NLB to expose the NGINX ingress controller using AWS Load Balancer Controller [here](https://kubernetes.github.io/ingress-nginx/deploy/#aws).
