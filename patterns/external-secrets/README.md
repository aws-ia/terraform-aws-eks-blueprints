# Amazon EKS Cluster w/ External Secrets Operator

This pattern deploys an EKS Cluster with the External Secrets Operator.
The cluster is populated with a ClusterSecretStore and SecretStore example
using SecretManager and Parameter Store respectively. A secret for each
store is also created. Both stores use IRSA to retrieve the secret values from AWS.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. List the secret resources in the `external-secrets` namespace

    ```sh
    kubectl get externalsecrets -n external-secrets
    kubectl get secrets -n external-secrets
    ```

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
