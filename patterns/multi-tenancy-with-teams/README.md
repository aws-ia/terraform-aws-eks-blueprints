# Multi-Tenancy w/ Teams

This pattern demonstrates how to provision and configure a multi-tenancy Amazon EKS cluster with safeguards for resource consumption and namespace isolation.

This example solution provides:

- Two development teams - `team-red` and `team-blue` - isolated to their respective namespaces
- An admin team with privileged access to the cluster (`team-admin`)

## Prerequisites

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#prerequisites) for the prerequisites required to deploy this pattern and steps to deploy.

## Validate

!!! danger "TODO"
    Add in validation steps

## Destroy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#destroy) for steps to clean up the resources created.
