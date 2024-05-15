---
title: Addons
---

# Migrate to EKS Blueprints Addons Module

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
module "eks_blueprints_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"

  eks_cluster_id       = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_oidc_provider    = module.eks.oidc_provider
  eks_cluster_version  = module.eks.cluster_version

  # TODO

}
```

### After - v5.x Example

```hcl
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # TODO

}
```

### Diff of Before vs After

```diff
module "eks_blueprints_addons" {
-  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"
+  source  = "aws-ia/eks-blueprints-addons/aws"
+  version = "~> 1.0"

  # TODO
}
```

### State Move Commands

In conjunction with the changes above, users can elect to move their external capacity provider(s) under this module using the following move command. Command is shown using the values from the example shown above, please update to suit your configuration names:

```sh
terraform state mv 'xxx' 'yyy'
```
