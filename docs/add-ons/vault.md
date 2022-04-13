# HashiCorp Vault

[HashiCorp Vault](https://www.vaultproject.io) brokers and deeply integrates with trusted identities to automate access to secrets, data, and systems.

This add-on is implemented as an external add-on. For detailed documentation and usage of the add-on please refer to the add-on [repository](https://github.com/hashicorp/hashicorp-vault-eks-blueprints-addon).

## Example

Checkout the full [example](https://github.com/hashicorp/hashicorp-vault-eks-blueprints-addon/tree/main/blueprints/getting-started).

## Usage

This step deploys the [HashiCorp Vault](https://www.vaultproject.io) with default Helm Chart config

```hcl
  enable_vault = true
```

Alternatively, you can override the helm values by using the code snippet below

```hcl
  enable_vault = true
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```hcl
vault = {
  enable = true
}
```
