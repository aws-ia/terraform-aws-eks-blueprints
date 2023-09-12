# Multi-Tenancy w/ Teams

This pattern demonstrates how to provision and configure a multi-tenancy Amazon EKS cluster with safeguards for resource consumption and namespace isolation.

This example solution provides:

- Two development teams - `team-red` and `team-blue` - isolated to their respective namespaces
- An admin team with privileged access to the cluster (`team-admin`)

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

!!! danger "TODO"
    Add in validation steps

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
