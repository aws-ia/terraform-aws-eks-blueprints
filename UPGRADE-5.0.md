# Upgrade from v4.x to v5.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

#### ⚠️ This guide is under active development. As tasks for v5.0 are implemented, the associated upgrade guidance/changes are documented here. See [here](https://github.com/aws-ia/terraform-aws-eks-blueprints/milestone/1) to track progress of v5.0 implementation

## List of backwards incompatible changes

-

## Additional changes

### Added

- Usage of KMS module provided by upstreams ([terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) and [terraform-aws-kms](https://github.com/terraform-aws-modules/terraform-aws-kms))

### Modified

-

### Removed

- Local implementation of KMS module

### Variable and output changes

1. Removed variables:

    -

2. Renamed variables:

    -

3. Added variables:

    -

4. Removed outputs:

    -

5. Renamed outputs:

    -

6. Added outputs:

    -

## Upgrade Migrations

### Before - v4.x Example

```hcl
module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.4.0"

  # TODO

}
```

### After - v5.x Example

```hcl
module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v5.0.0"

  # TODO

}
```

### Diff of Before vs After

```diff
module "eks_blueprints" {
-  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.4.0"
+  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v5.0.0"

  # TODO
}
```

### State Move Commands

In conjunction with the changes above, users can elect to move their external capacity provider(s) under this module using the following move command. Command is shown using the values from the example shown above, please update to suit your configuration names:

KMS:

```sh
terraform state mv 'module.eks_blueprints.module.kms[0].aws_kms_alias.this' 'module.eks_blueprints.module.aws_eks.module.kms.aws_kms_alias.this["ipv4-prefix-delegation"]'
# Make sure to replace the alias from "ipv4-prefix-delegation" to what you have. You can verify it by checking the output of  the terraform plan, in examples format, it should be the example name.

terraform state mv 'module.eks_blueprints.module.kms[0].aws_kms_key.this' 'module.eks_blueprints.module.aws_eks.module.kms.aws_kms_key.this[0]'

#If used fluent bit addon
terraform state mv 'module.eks_blueprints_kubernetes_addons.module.aws_for_fluent_bit[0].module.kms[0].aws_kms_key.this' 'module.eks_blueprints_kubernetes_addons.module.aws_for_fluent_bit[0].module.kms.aws_kms_key.this[0]'
# Same as above, make sure to replace the alias from "ipv4-prefix-delegation-cw-fluent-bit" to what you have. You can verify it by checking the output of  the terraform plan, in examples format, it should be the example name.
terraform state mv 'module.eks_blueprints_kubernetes_addons.module.aws_for_fluent_bit[0].module.kms[0].aws_kms_alias.this' 'module.eks_blueprints_kubernetes_addons.module.aws_for_fluent_bit[0].module.kms.aws_kms_alias.this["fluent-bit"]'
```
