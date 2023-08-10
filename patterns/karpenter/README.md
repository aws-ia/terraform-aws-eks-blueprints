# Karpenter

This example demonstrates how to provision a Karpenter on a serverless cluster (serverless data plane) using Fargate Profiles.

This example solution provides:

- Amazon EKS Cluster (control plane)
- Amazon EKS Fargate Profiles for the `kube-system` namespace which is used by the `coredns`, `vpc-cni`, and `kube-proxy` addons, as well as profile that will match on the `karpenter` namespace which will be used by Karpenter.
- Amazon EKS managed addons `coredns`, `vpc-cni` and `kube-proxy`
    `coredns` has been patched to run on Fargate, and `vpc-cni` has been configured to use prefix delegation to better support the max pods setting of 110 on the Karpenter provisioner
- A sample deployment is provided to demonstrates scaling a deployment to view how Karpenter responds to provision, and de-provision, resources on-demand

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply -target module.vpc
terraform apply -target module.eks
terraform apply
```

Enter `yes` at command prompt to apply

## Destroy

To teardown and remove the resources created in this example:

```sh
kubectl delete deployment inflate
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -auto-approve
```
