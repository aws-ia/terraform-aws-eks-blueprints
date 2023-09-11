# Karpenter

This pattern demonstrates how to provision Karpenter on a serverless cluster (serverless data plane) using Fargate Profiles.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#prerequisites) for the prerequisites required to deploy this pattern and steps to deploy.

## Validate

!!! danger "TODO"
    Add in validation steps

## Destroy

First, scale down the deployment to de-provision Karpenter created resources:

```sh
kubectl delete deployment inflate
```

Finally, see [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#destroy) for steps to clean up the resources created.
