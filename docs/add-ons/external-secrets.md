
# External Secrets Operator

[External Secrets Operator](https://external-secrets.io/latest) is a Kubernetes operator that integrates external secret management systems like AWS Secrets Manager, HashiCorp Vault, Google Secrets Manager, Azure Key Vault and many more. The operator reads information from external APIs and automatically injects the values into a Kubernetes Secret.

## Usage

The External Secrets Operator can be deployed by enabling the add-on via the following.

```hcl
enable_external_secrets = true
```

You can optionally customize the Helm chart that deploys the operator via the following configuration.

```hcl
  enable_external_secrets = true
  external_secrets_helm_config = {
    name                       = "external-secrets"
    chart                      = "external-secrets"
    repository                 = "https://charts.external-secrets.io/"
    version                    = "0.5.9"
    namespace                  = "external-secrets"
  }
```

###  GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

Refer to [locals.tf](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/external-secrets/locals.tf) for latest config. GitOps with ArgoCD Add-on repo is located [here](https://github.com/aws-samples/eks-blueprints-add-ons/blob/main/chart/values.yaml).

```hcl
  argocd_gitops_config = {
    enable = true
  }
```
