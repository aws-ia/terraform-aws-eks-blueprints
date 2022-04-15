# HashiCorp Vault

[HashiCorp Vault](https://www.vaultproject.io) brokers and deeply integrates with trusted identities to automate access to secrets, data, and systems.

This add-on is implemented as an external add-on. For detailed documentation and usage of the add-on please refer to the add-on [repository](https://github.com/hashicorp/terraform-aws-hashicorp-vault-eks-addon).

## Example

Checkout the full [example](https://github.com/hashicorp/terraform-aws-hashicorp-vault-eks-addon/tree/main/blueprints/getting-started).

## Usage

This step deploys the [HashiCorp Vault](https://www.vaultproject.io) with default Helm Chart config

```hcl
  enable_vault = true
```

Alternatively, you can override the Helm Values by setting the `vault_helm_config` object, like shown in the code snippet below:

```hcl
  enable_vault = true

  vault_helm_config = {
    name       = "vault"                                          # (Required) Release name.
    chart      = "vault"                                          # (Required) Chart name to be installed.
    repository = "https://helm.releases.hashicorp.com"            # (Optional) Repository URL where to locate the requested chart.
    version    = "v0.19.0"                                        # (Optional) Specify the exact chart version to install.

    # ...
  }
```

This snippet does not contain _all_ available options that can be set as part of `vault_helm_config`. For the complete listing, see the [`hashicorp-vault-eks-blueprints-addon` repository](https://github.com/hashicorp/terraform-aws-hashicorp-vault-eks-addon/blob/main/locals.tf).
