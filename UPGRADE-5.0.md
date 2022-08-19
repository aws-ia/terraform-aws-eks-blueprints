# Upgrade from v4.x to v5.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

#### ⚠️ This guide is under active development. As tasks for v5.0 are implemented, the associated upgrade guidance/changes are documented here. See [here](https://github.com/aws-ia/terraform-aws-eks-blueprints/milestone/1) to track progress of v5.0 implementation

Note: if your configuration utilizes explicit `depends_on` configurations, it might be worthwhile to disable (comment out) during migration to reduce the amount of changes impacted during migration. The explicit `depends_on` configuration will force any downstream configurations affected by the changed resource to be [re-evaluated and re-computed](https://github.com/hashicorp/terraform/issues/30340#issuecomment-1010202582).

## List of backwards incompatible changes

- Fargate profile sub-module has been replaced with the implementation provided by [`terraform-aws-eks/modules/fargate-profile](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/fargate-profile)
- Fargate profile variable `var.fargate_profiles` definition has been updated to match that used by [`terraform-aws-eks/modules/fargate-profile](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/fargate-profile)

## Additional changes

### Added

- Usage of KMS module provided by upstreams ([terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) and [terraform-aws-kms](https://github.com/terraform-aws-modules/terraform-aws-kms))

### Modified

-

### Removed

- Local implementation of KMS module

### Variable and output changes

1. Removed variables:

    - Fargate profiles:
      - `subnet_ids`
      - `context`

2. Renamed variables:

    - Fargate profiles:
      - `fagate_profiles["<name>"].fargate_profile_name` has been renamed to `fargate_profiles["<name>"].name`
      - `fagate_profiles["<name>"].fargate_profile_namespaces` has been renamed to `fargate_profiles["<name>"].selectors`
      - `fagate_profiles["<name>"].fargate_profile_namespaces.k8s_labels` has been renamed to `fargate_profiles["<name>"].selectors.labels`
      - `fagate_profiles["<name>"].additional_tags` has been renamed to `fargate_profiles["<name>"].tags`

3. Added variables:

    - Fargate profiles:
      - `fargate_profile_defaults` to allow setting common parameters once across all Fargate profiles created (and can be overriden by individual Fargate profile definitions)

4. Removed outputs:

    - Fargate profiles:
      - `fargate_profiles_iam_role_arns`
      - `fargate_profiles_aws_auth_config_map`

5. Renamed outputs:

    -

6. Added outputs:

    -

## Upgrade Migrations

### Before - v4.x Example

```hcl
module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.7.0"

  cluster_name    = "upgrade"
  cluster_version = "1.20"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # Fargate
  fargate_profiles = {
    default = {
      fargate_profile_name = "default"
      fargate_profile_namespaces = [
        {
          namespace = "default"
        }
      ]

      additional_tags = {
        ExtraTag = "Fargate"
      }

      subnet_ids = module.vpc.private_subnets
    }
  }
}
```

### After - v5.x Example

```hcl
module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v5.0.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.22"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # Fargate
  fargate_profile_defaults = {
    # To maintain backwards compatibility w/ v4.x
    iam_role_use_name_prefix   = false
    iam_role_attach_cni_policy = false
  }

  fargate_profiles = {
    default = {
      name          = "default"
      iam_role_name = "${local.cluster_name}-default" # To maintain backwards compatibility w/ v4.x
      selectors = [
        {
          namespace = "default"
        }
      ]

      tags = {
        ExtraTag = "Fargate"
      }
    }
  }
}
```

### Diff of Before vs After

```diff
module "eks_blueprints" {
-  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.7.0"
+  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v5.0.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.22"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # Fargate
  fargate_profiles = {
    default = {
-      fargate_profile_name = "default"
+      name = "default"
-      fargate_profile_namespaces = [
+      selectors = [
        {
          namespace = "default"
        }
      ]
-      additional_tags = {
+      tags = {
        ExtraTag = "Fargate"
      }

-      subnet_ids = module.vpc.private_subnets
    }
  }
}
```

### State Move Commands

In conjunction with the changes above, users can elect to move their external capacity provider(s) under this module using the following move command. Command is shown using the values from the example shown above, please update to suit your configuration names:

#### KMS Key

```sh
terraform state mv 'module.eks_blueprints.module.kms[0].aws_kms_alias.this' 'module.eks_blueprints.module.aws_eks.module.kms.aws_kms_alias.this["ipv4-prefix-delegation"]'
# Make sure to replace the alias from "ipv4-prefix-delegation" to what you have. You can verify it by checking the output of  the terraform plan, in examples format, it should be the example name.

terraform state mv 'module.eks_blueprints.module.kms[0].aws_kms_key.this' 'module.eks_blueprints.module.aws_eks.module.kms.aws_kms_key.this[0]'

#If used fluent bit addon
terraform state mv 'module.eks_blueprints_kubernetes_addons.module.aws_for_fluent_bit[0].module.kms[0].aws_kms_key.this' 'module.eks_blueprints_kubernetes_addons.module.aws_for_fluent_bit[0].module.kms.aws_kms_key.this[0]'
# Same as above, make sure to replace the alias from "ipv4-prefix-delegation-cw-fluent-bit" to what you have. You can verify it by checking the output of  the terraform plan, in examples format, it should be the example name.
terraform state mv 'module.eks_blueprints_kubernetes_addons.module.aws_for_fluent_bit[0].module.kms[0].aws_kms_alias.this' 'module.eks_blueprints_kubernetes_addons.module.aws_for_fluent_bit[0].module.kms.aws_kms_alias.this["fluent-bit"]'
```

#### Fargate Profiles

Please replace `<PROFILE_KEY>` with the name of the associated key for the Fargate profile definition that is being migrated across versions; all three state move commands are to be applied per Fargate profile to be migrated:
```sh
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["<PROFILE_KEY>"].aws_eks_fargate_profile.eks_fargate' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["<PROFILE_KEY>"].aws_eks_fargate_profile.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["<PROFILE_KEY>"].aws_iam_role.fargate[0]' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["<PROFILE_KEY>"].aws_iam_role.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["<PROFILE_KEY>"].aws_iam_role_policy_attachment.fargate_pod_execution_role_policy["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["<PROFILE_KEY>"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]'
```

For the `examples/fargate-serverless` example, the move commands are:
```sh
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["default"].aws_eks_fargate_profile.eks_fargate' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["default"].aws_eks_fargate_profile.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["default"].aws_iam_role.fargate[0]' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["default"].aws_iam_role.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["default"].aws_iam_role_policy_attachment.fargate_pod_execution_role_policy["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["default"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]'

terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["kube_system"].aws_eks_fargate_profile.eks_fargate' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["kube_system"].aws_eks_fargate_profile.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["kube_system"].aws_iam_role.fargate[0]' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["kube_system"].aws_iam_role.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["kube_system"].aws_iam_role_policy_attachment.fargate_pod_execution_role_policy["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["kube_system"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]'

terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["alb_sample_app"].aws_eks_fargate_profile.eks_fargate' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["alb_sample_app"].aws_eks_fargate_profile.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["alb_sample_app"].aws_iam_role.fargate[0]' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["alb_sample_app"].aws_iam_role.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["alb_sample_app"].aws_iam_role_policy_attachment.fargate_pod_execution_role_policy["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["alb_sample_app"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]'
```
