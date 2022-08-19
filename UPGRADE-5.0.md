# Upgrade from v4.x to v5.x

Please consult the `examples` directory for reference example configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

#### ⚠️ This guide is under active development. As tasks for v5.0 are implemented, the associated upgrade guidance/changes are documented here. See [here](https://github.com/aws-ia/terraform-aws-eks-blueprints/milestone/1) to track progress of v5.0 implementation

Note: if your configuration utilizes explicit `depends_on` configurations, it might be worthwhile to disable (comment out) during migration to reduce the amount of changes impacted during migration. The explicit `depends_on` configuration will force any downstream configurations affected by the changed resource to be [re-evaluated and re-computed](https://github.com/hashicorp/terraform/issues/30340#issuecomment-1010202582).

## List of backwards incompatible changes

- Fargate profile sub-module has been replaced with the implementation provided by [`terraform-aws-eks/modules/fargate-profile](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/fargate-profile)
- Fargate profile variable `var.fargate_profiles` definition has been updated to match that used by [`terraform-aws-eks/modules/fargate-profile](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/fargate-profile)
- Self-managed node group sub-module has been replaced with the implementation provided by [`terraform-aws-eks/modules/self-managed-node-group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/self-managed-node-group)
- Self-managed node group variable `var.self_managed_node_groups` definition has been updated to match that used by [`terraform-aws-eks/modules/self-managed-node-group](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/self-managed-node-group)


## Additional changes

### Added

-

### Modified

- The local KMS module has been replaced by what is provided by [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) and [terraform-aws-kms](https://github.com/terraform-aws-modules/terraform-aws-kms)

### Removed

- Local implementation of KMS module

### Variable and output changes

1. Removed variables:

    - Fargate profile:
      - `subnet_ids`
      - `context`
    - Self managed node group:
      - `context`

2. Renamed variables:

    -

3. Added variables:

    - Fargate profile:
      - `fargate_profile_defaults` to allow setting common parameters once across all Fargate profiles created (and can be overriden by individual Fargate profile definitions)
      - `self_managed_node_group_defaults` to allow setting common parameters once across all self-managed node groups created (and can be overriden by individual self-managed node group definitions)

4. Removed outputs:

    - Fargate profile:
      - `fargate_profiles_iam_role_arns`
      - `fargate_profiles_aws_auth_config_map`
    - Self managed node group:
      - `self_managed_node_group_iam_role_arns`
      - `self_managed_node_group_autoscaling_groups`
      - `self_managed_node_group_iam_instance_profile_id`
      - `self_managed_node_group_aws_auth_config_map`
      - `windows_node_group_aws_auth_config_map`

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

  # Self-Managed Node Group(s)
  self_managed_node_groups = {
    self_mg5 = {
      node_group_name = "self_mg5"

      subnet_type            = "private"
      subnet_ids             = module.vpc.private_subnets
      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"
      custom_ami_id          = ""

      format_mount_nvme_disk = true
      public_ip              = false
      enable_monitoring      = false

      enable_metadata_options = false

      pre_userdata = <<-EOT
        yum install -y amazon-ssm-agent
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
      EOT

      kubelet_extra_args   = "--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=test=true:NoSchedule --max-pods=20"
      bootstrap_extra_args = "--use-max-pods false"

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 50
        },
        {
          device_name = "/dev/xvdf"
          volume_type = "gp3"
          volume_size = 80
          iops        = 3000
          throughput  = 125
        },
        {
          device_name = "/dev/xvdg"
          volume_type = "gp3"
          volume_size = 100
          iops        = 3000
          throughput  = 125
        }
      ]

      instance_type = "m5.large"
      desired_size  = 2
      max_size      = 10
      min_size      = 2
      capacity_type = ""

      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }
    }
    spot_4vcpu_16mem = {
      node_group_name    = "smng-spot-4vcpu-16mem"
      capacity_type      = "spot"
      capacity_rebalance = true
      instance_types     = ["m5.xlarge", "m4.xlarge", "m6a.xlarge", "m5a.xlarge", "m5d.xlarge"]
      min_size           = 1
      subnet_ids         = module.vpc.private_subnets
      launch_template_os = "amazonlinux2eks"
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

  # Self-Managed Node Group(s)
  self_managed_node_group_defaults = {
    create_security_group = false

    # Backwards compatibility
    launch_template_use_name_prefix = false
    iam_role_use_name_prefix        = false
    use_name_prefix                 = false

    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 50
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          encrypted             = true
          delete_on_termination = true
        }
      }
    ]

    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }

  self_managed_node_groups = {
    self_mg5 = {
      name = "migrate-self_mg5"

      launch_template_name = "self_mg5-migrate"
      iam_role_name        = "migrate-self_mg5"
      metadata_options     = {}
      autoscaling_group_tags = {
        "k8s.io/cluster-autoscaler/enabled"                              = "TRUE"
        "k8s.io/cluster-autoscaler/migrate"                              = "owned"
        "k8s.io/cluster-autoscaler/node-template/label/eks/capacityType" = "on_demand"
        "k8s.io/cluster-autoscaler/node-template/label/eks/nodegroup"    = "self_mg5"
      }

      pre_bootstrap_user_data = <<-EOT
        yum install -y amazon-ssm-agent
        systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
      EOT

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=test=true:NoSchedule --max-pods=20' --use-max-pods false"

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          ebs = {
            volume_type = "gp3"
            volume_size = 50
          }
        },
        {
          device_name = "/dev/xvdf"
          ebs = {
            volume_type = "gp3"
            volume_size = 80
            iops        = 3000
            throughput  = 125
          }
        },
        {
          device_name = "/dev/xvdg"
          ebs = {
            volume_type = "gp3"
            volume_size = 100
            iops        = 3000
            throughput  = 125
          }
        }
      ]

      instance_type = "m5.large"
      desired_size  = 2
      max_size      = 10
      min_size      = 2

      tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }
    }

    spot_4vcpu_16mem = {
      name = "migrate-smng-spot-4vcpu-16mem"

      launch_template_name = "smng-spot-4vcpu-16mem-migrate"
      iam_role_name        = "migrate-smng-spot-4vcpu-16mem"
      autoscaling_group_tags = {
        "k8s.io/cluster-autoscaler/enabled"                              = "TRUE"
        "k8s.io/cluster-autoscaler/migrate"                              = "owned"
        "k8s.io/cluster-autoscaler/node-template/label/eks/capacityType" = "spot"
        "k8s.io/cluster-autoscaler/node-template/label/eks/nodegroup"    = "smng-spot-4vcpu-16mem"
      }

      min_size = 1

      capacity_rebalance         = true
      use_mixed_instances_policy = true
      mixed_instances_policy = {
        override = [
          { instance_type = "m5.xlarge" },
          { instance_type = "m4.xlarge" },
          { instance_type = "m6a.xlarge" },
          { instance_type = "m5a.xlarge" },
          { instance_type = "m5d.xlarge" },
        ]
      }
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

For the example above, the move commands are:
```sh
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["default"].aws_eks_fargate_profile.eks_fargate' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["default"].aws_eks_fargate_profile.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["default"].aws_iam_role.fargate[0]' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["default"].aws_iam_role.this[0]'
terraform state mv 'module.eks_blueprints.module.aws_eks_fargate_profiles["default"].aws_iam_role_policy_attachment.fargate_pod_execution_role_policy["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]' 'module.eks_blueprints.module.aws_eks.module.fargate_profile["default"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]'
```

#### Self-Managed Node Groups

Please replace `<NODE_GROUP>` with the name of the associated key for the Fargate profile definition that is being migrated across versions; all three state move commands are to be applied per Fargate profile to be migrated:

```sh
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["<NODE_GROUP>"].module.launch_template_self_managed_ng.aws_launch_template.this["self-managed-node-group"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["<NODE_GROUP>"].aws_launch_template.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["<NODE_GROUP>"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["<NODE_GROUP>"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["<NODE_GROUP>"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["<NODE_GROUP>"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["<NODE_GROUP>"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["<NODE_GROUP>"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["<NODE_GROUP>"].aws_iam_role.self_managed_ng[0]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["<NODE_GROUP>"].aws_iam_role.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["<NODE_GROUP>"].aws_iam_instance_profile.self_managed_ng[0]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["<NODE_GROUP>"].aws_iam_instance_profile.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["<NODE_GROUP>"].aws_autoscaling_group.self_managed_ng' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["<NODE_GROUP>"].aws_autoscaling_group.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["<NODE_GROUP>"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]' ' module.eks_blueprints.module.aws_eks.module.self_managed_node_group["<NODE_GROUP>"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]'
```

For the example above, the move commands are:
```sh
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["spot_4vcpu_16mem"].module.launch_template_self_managed_ng.aws_launch_template.this["self-managed-node-group"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["spot_4vcpu_16mem"].aws_launch_template.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["spot_4vcpu_16mem"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["spot_4vcpu_16mem"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["spot_4vcpu_16mem"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["spot_4vcpu_16mem"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["spot_4vcpu_16mem"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["spot_4vcpu_16mem"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["spot_4vcpu_16mem"].aws_iam_role.self_managed_ng[0]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["spot_4vcpu_16mem"].aws_iam_role.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["spot_4vcpu_16mem"].aws_iam_instance_profile.self_managed_ng[0]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["spot_4vcpu_16mem"].aws_iam_instance_profile.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["spot_4vcpu_16mem"].aws_autoscaling_group.self_managed_ng' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["spot_4vcpu_16mem"].aws_autoscaling_group.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["spot_4vcpu_16mem"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]' ' module.eks_blueprints.module.aws_eks.module.self_managed_node_group["spot_4vcpu_16mem"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]'

tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["self_mg5"].module.launch_template_self_managed_ng.aws_launch_template.this["self-managed-node-group"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["self_mg5"].aws_launch_template.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["self_mg5"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["self_mg5"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["self_mg5"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["self_mg5"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["self_mg5"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["self_mg5"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["self_mg5"].aws_iam_role.self_managed_ng[0]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["self_mg5"].aws_iam_role.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["self_mg5"].aws_iam_instance_profile.self_managed_ng[0]' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["self_mg5"].aws_iam_instance_profile.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["self_mg5"].aws_autoscaling_group.self_managed_ng' 'module.eks_blueprints.module.aws_eks.module.self_managed_node_group["self_mg5"].aws_autoscaling_group.this[0]'
tf state mv 'module.eks_blueprints.module.aws_eks_self_managed_node_groups["self_mg5"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]' ' module.eks_blueprints.module.aws_eks.module.self_managed_node_group["self_mg5"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]'
```
