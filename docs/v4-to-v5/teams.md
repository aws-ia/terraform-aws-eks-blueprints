---
title: Teams
---

# Migrate to EKS Blueprints Teams Module

Please consult the [docs/v4-to-v5/example](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/docs/v4-to-v5/example) directory for reference configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

#### ⚠️ This guide is under active development.

## List of backwards incompatible changes

-

## Additional changes

### Added

-

### Modified

-

### Removed

-

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
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1"

  # TODO

}
```

### After - v5.x Example

```hcl
module "eks_blueprints_teams" {
  source  = "aws-ia/eks-blueprints-teams/aws"
  version = "~> 0.3"

  # TODO

}
```

### Diff of Before vs After

```diff
module "eks_blueprints_teams" {
-  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1"
+  source  = "aws-ia/eks-blueprints-teams/aws"
+  version = "~> 0.3"

  # TODO
}
```

### State Move Commands

In conjunction with the changes above, users can elect to move their external capacity provider(s) under this module using the following move command. Command is shown using the values from the example shown above, please update to suit your configuration names:

```sh
terraform state mv 'xxx' 'yyy'
```
