# Multi-Tenancy w/ Teams

This example demonstrates how to provision and configure a multi-tenancy Amazon EKS cluster with safeguards for resource consumption and namespace isolation.

This example solution provides:

- Amazon EKS Cluster (control plane)
- Amazon EKS managed nodegroup (data plane)
- Two development teams - `team-red` and `team-blue` - isolated to their respective namespaces
- An admin team with privileged access to the cluster (`team-admin`)

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl`.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -auto-approve
```
