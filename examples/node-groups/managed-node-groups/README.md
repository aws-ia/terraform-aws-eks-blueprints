# EKS Cluster with Managed Node Group

This example deploys a new EKS Cluster with a Managed node group into a new VPC.

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates an Internet gateway for the Public Subnets and a NAT Gateway for the Private Subnets
- Creates an EKS Cluster Control plane with Managed node groups

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
cd examples/node-groups/managed-node-groups/
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

    $ aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>

#### Step 6: List all the worker nodes by running the command below

    $ kubectl get nodes

#### Step 7: List all the pods running in `kube-system` namespace

    $ kubectl get pods -n kube-system

#### Step 8: Deploy a pod on the spots nodegroups (spot_2vcpu_8mem and spot_4vcpu_16mem)

Remember:

- we created the spot_2vcpu_8mem nodegroup with a desired of 1 a min of 1 and a max of 2.
- we created the spot_4vcpu_16mem nodegroup with a desired of 0 a min of 0 and a max of 3.
- cluster-autoscaler is configured with priority expander with a priority on spot_2vcpu_8mem and then on spot_4vcpu_16mem and then any matching nodegroup

Create a deployment with kubernetes/nginx-spot.yaml, which request spot instance through it's node selector and tolerate them:

```bash
kubectl apply -f kubernetes/nginx-spot.yaml
```

If we scale the deployment, it will fullfill first the 2 nodes in the nodegroup spot_2vcpu_8mem

```bash
kubectl scale deployment/nginx-spot --replicas=10
```

If we scale again, it will need more nodes and will scale the nodegroup spot_4vcpu_16mem from 0.

```bash
kubectl scale deployment/nginx-spot --replicas=20
```

## Cleanup

To clean up your environment, first remove your workloads:

```bash
kubectl delete -f kubernetes/nginx-spot.yaml
```

Node group spot_2vcpu_8mem will scale down to 1 and node group spot_2vcpu_16mem will scale down to 0.

then destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
```
