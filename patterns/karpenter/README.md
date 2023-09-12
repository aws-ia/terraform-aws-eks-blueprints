# Karpenter

This pattern demonstrates how to provision Karpenter on a serverless cluster (serverless data plane) using Fargate Profiles.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

!!! danger "TODO"
    Add in validation steps

## Destroy

Scale down the deployment to de-provision Karpenter created resources first:

```sh
kubectl delete deployment inflate
```

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
