# Getting Started

This getting started guide will help you deploy your first EKS environment using EKS Blueprints.

## Prerequisites:

First, ensure that you have installed the following tools locally.

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deployment Steps

The following steps will walk you through the deployment of an [example blueprint](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/examples/eks-cluster-with-new-vpc/main.tf). This example will deploy a new VPC, a private EKS cluster with public and private subnets, and one managed node group that will be placed in the private subnets. The example will also deploy the following add-ons into the EKS cluster:

- AWS Load Balancer Controller
- Cluster Autoscaler
- CoreDNS
- kube-proxy
- Metrics Server
- vpc-cni

### Clone the repo

```
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

### Terraform INIT

CD into the example directory:

```
cd examples/eks-cluster-with-new-vpc/
```

Initialize the working directory with the following:

```
terraform init
```

### Terraform PLAN

Verify the resources that will be created by this execution:

```
terraform plan
```

### Terraform APPLY

We will leverage Terraform's [target](https://learn.hashicorp.com/tutorials/terraform/resource-targeting?in=terraform/cli) functionality to deploy a VPC, an EKS Cluster, and Kubernetes add-ons in separate steps.

**Deploy the VPC**. This step will take roughly 3 minutes to complete.

```
terraform apply -target="module.vpc"
```

**Deploy the EKS cluster**. This step will take roughly 14 minutes to complete.

```
terraform apply -target="module.eks_blueprints"
```

**Deploy the add-ons**. This step will take rough 5 minutes to complete.

```
terraform apply -target="module.eks_blueprints_kubernetes_addons"
```

## Configure kubectl

Terraform output will display a command in your console that you can use to bootstrap your local `kubeconfig`.

```
configure_kubectl = "aws eks --region <region> update-kubeconfig --name <cluster-name>"
```

Run the command in your terminal.

```
aws eks --region <region> update-kubeconfig --name <cluster-name>
```

## Validation

### List worker nodes

```
kubectl get nodes
```

You should see output similar to the following:

```
NAME                                        STATUS   ROLES    AGE     VERSION
ip-10-0-10-161.us-west-2.compute.internal   Ready    <none>   4h18m   v1.21.5-eks-9017834
ip-10-0-11-171.us-west-2.compute.internal   Ready    <none>   4h18m   v1.21.5-eks-9017834
ip-10-0-12-48.us-west-2.compute.internal    Ready    <none>   4h18m   v1.21.5-eks-9017834
```

### List pods

```
kubectl get pods -n kube-system
```

You should see output similar to the following:

```
NAME                                                        READY   STATUS    RESTARTS   AGE
aws-load-balancer-controller-954746b57-k9lhc                1/1     Running   1          15m
aws-load-balancer-controller-954746b57-q5gh4                1/1     Running   1          15m
aws-node-jlnkd                                              1/1     Running   1          15m
aws-node-k86pv                                              1/1     Running   0          12m
aws-node-kjcdg                                              1/1     Running   1          14m
cluster-autoscaler-aws-cluster-autoscaler-5d4446b58-d6frd   1/1     Running   1          15m
coredns-85d5b4454c-jksbw                                    1/1     Running   1          24m
coredns-85d5b4454c-x7wwd                                    1/1     Running   1          24m
kube-proxy-92slm                                            1/1     Running   1          18m
kube-proxy-bz5kb                                            1/1     Running   1          18m
kube-proxy-zl7cj                                            1/1     Running   1          18m
metrics-server-694d47d564-hzd8h                             1/1     Running   1          15m
```

## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the add-ons.

```
terraform destroy -target="module.eks_blueprints_kubernetes_addons"
```

Destroy the EKS cluster.

```
terraform destroy -target="module.eks_blueprints"
```

Destroy the VPC.

```
terraform destroy -target="module.vpc"
```
