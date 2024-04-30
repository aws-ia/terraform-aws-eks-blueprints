---
title: Cluster
---

# Migrate to EKS Module v19.x

Please consult the [docs/v4-to-v5/example](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/docs/v4-to-v5/example) directory for reference configurations. If you find a bug, please open an issue with supporting configuration to reproduce.

## Backwards incompatible changes

- The cluster module provided in EKS Blueprints is being removed entirely from the project. Instead, users are encouraged to use the [`terraform-aws-eks` module](https://github.com/terraform-aws-modules/terraform-aws-eks) for creating and managing their EKS cluster in Terraform.
- The KMS module provided in EKS Blueprints has been removed. Users can leverage the KMS creation/management functionality provided by the [`terraform-aws-eks` module](https://github.com/terraform-aws-modules/terraform-aws-eks) or utilize the standalone [`terraform-aws-kms` module](https://github.com/terraform-aws-modules/terraform-aws-kms).
- The EMR on EKS module provided in EKS Blueprints has been removed. Instead, users are encouraged to use the [`terraform-aws-emr` virtual cluster sub-module](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/modules/virtual-cluster) for creating and managing their EMR on EKS virtual cluster in Terraform.
- The teams multi-tenancy module provided in EKS Blueprints has been removed. Instead, users are encouraged to use the [`terraform-aws-eks-blueprints-teams` module](https://github.com/aws-ia/terraform-aws-eks-blueprints-teams) for creating and managing their multi-tenancy constructions within their EKS clusters in Terraform.

## Additional changes

### Added

- N/A

### Modified

- N/A

### Removed

- All noted above under `Backwards incompatible changes`

### Variable and output changes

Since the change is to replace the EKS Blueprints cluster module with the [`terraform-aws-eks` module](https://github.com/terraform-aws-modules/terraform-aws-eks), there aren't technically any variable or output changes other than their removal. Please consult the [`terraform-aws-eks` module](https://github.com/terraform-aws-modules/terraform-aws-eks) for its respective variables/outputs.

1. Removed variables:

    - All

2. Renamed variables:

    - None

3. Added variables:

    - None

4. Removed outputs:

    - All

5. Renamed outputs:

    - None

6. Added outputs:

    - None

## Upgrade Migrations

### Before - v4.32 Example

```hcl
module "eks" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1"

  cluster_name    = local.name
  cluster_version = "1.26"

  vpc_id                          = module.vpc.vpc_id
  private_subnet_ids              = module.vpc.private_subnets
  cluster_endpoint_private_access = true

  map_roles = [
    {
      rolearn  = data.aws_caller_identity.current.arn
      username = "me"
      groups   = ["system:masters"]
    },
  ]

  managed_node_groups = {
    managed = {
      node_group_name = "managed"
      instance_types  = ["m5.large"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      k8s_labels = {
        Which = "managed"
      }
    }
  }

  fargate_profiles = {
    fargate = {
      fargate_profile_name = "fargate"
      fargate_profile_namespaces = [{
        namespace = "default"

        k8s_labels = {
          Which = "fargate"
        }
      }]
      subnet_ids = module.vpc.private_subnets
    }
  }

  self_managed_node_groups = {
    self_managed = {
      node_group_name    = "self_managed"
      instance_type      = "m5.large"
      launch_template_os = "amazonlinux2eks"

      min_size     = 1
      max_size     = 2
      desired_size = 1

      k8s_labels = {
        Which = "self-managed"
      }
    }
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}
```

### After - v5.0 Example

Any of the values that are marked with `# Backwards compat` are provided to demonstrate configuration level changes to reduce the number of Terraform changes when migrating to the EKS module.

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = local.name
  cluster_version                = "1.26"
  cluster_endpoint_public_access = true # Backwards compat
  cluster_enabled_log_types      = ["api", "audit", "authenticator", "controllerManager", "scheduler"] # Backwards compat

  iam_role_name            = "${local.name}-cluster-role" # Backwards compat
  iam_role_use_name_prefix = false                        # Backwards compat

  kms_key_aliases = [local.name] # Backwards compat

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = data.aws_caller_identity.current.arn
      username = "me"
      groups   = ["system:masters"]
    },
  ]

  eks_managed_node_groups = {
    managed = {
      iam_role_name              = "${local.name}-managed" # Backwards compat
      iam_role_use_name_prefix   = false                   # Backwards compat
      use_custom_launch_template = false                   # Backwards compat

      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      labels = {
        Which = "managed"
      }
    }
  }

  fargate_profiles = {
    fargate = {
      iam_role_name            = "${local.name}-fargate" # Backwards compat
      iam_role_use_name_prefix = false                   # Backwards compat

      selectors = [{
        namespace = "default"
        labels = {
          Which = "fargate"
        }
      }]
    }
  }

  self_managed_node_groups = {
    self_managed = {
      name            = "${local.name}-self_managed" # Backwards compat
      use_name_prefix = false                        # Backwards compat

      iam_role_name            = "${local.name}-self_managed" # Backwards compat
      iam_role_use_name_prefix = false                        # Backwards compat

      launch_template_name            = "self_managed-${local.name}" # Backwards compat
      launch_template_use_name_prefix = false                        # Backwards compat

      instance_type = "m5.large"

      min_size     = 1
      max_size     = 2
      desired_size = 1

      labels = {
        Which = "self-managed"
      }
    }
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}
```

### Diff of Before vs After

```diff
module "eks" {
-  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1"
+  source  = "terraform-aws-modules/eks/aws"
+  version = "~> 19.13"

  cluster_name    = local.name
  cluster_version = "1.26"

  vpc_id                          = module.vpc.vpc_id
  private_subnet_ids              = module.vpc.private_subnets
+  cluster_endpoint_public_access  = true
-  cluster_endpoint_private_access = true

-  map_roles = [
+  aws_auth_roles = [
    {
      rolearn  = data.aws_caller_identity.current.arn
      username = "me"
      groups   = ["system:masters"]
    },
  ]

-  managed_node_groups = {
+  eks_managed_node_groups = {
    managed = {
-      node_group_name = "managed"
      instance_types  = ["m5.large"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

-      k8s_labels = {
+      labels = {
        Which = "managed"
      }
    }
  }

  fargate_profiles = {
    fargate = {
-      fargate_profile_name = "fargate"
-      fargate_profile_namespaces = [{
+      selectors = [{
        namespace = "default"

-        k8s_labels = {
+        labels = {
          Which = "fargate"
        }
      }]
-      subnet_ids = module.vpc.private_subnets
    }
  }

  self_managed_node_groups = {
    self_managed = {
-      node_group_name    = "self_managed"
      instance_type      = "m5.large"
-      launch_template_os = "amazonlinux2eks"

      min_size     = 1
      max_size     = 2
      desired_size = 1

-      k8s_labels = {
+      labels = {
        Which = "self-managed"
      }
    }
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}
```

### State Move Commands

The following Terraform state move commands are provided to aid in migrating the control plane and data plane components.

```sh
# This is not removing the configmap from the cluster -
# it will be adopted by the new module
terraform state rm 'module.eks.kubernetes_config_map.aws_auth[0]'

# Cluster
terraform state mv 'module.eks.module.aws_eks.aws_eks_cluster.this[0]' 'module.eks.aws_eks_cluster.this[0]'

# Cluster IAM role
terraform state mv 'module.eks.module.aws_eks.aws_iam_role.this[0]' 'module.eks.aws_iam_role.this[0]'
terraform state mv 'module.eks.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]' 'module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"]'
terraform state mv 'module.eks.module.aws_eks.aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"]' 'module.eks.aws_iam_role_policy_attachment.this["AmazonEKSVPCResourceController"]'

# Cluster primary security group tags
# Note: This will depend on the tags applied to the module - here we
#       are demonstrating the two tags used in the configuration above
terraform state mv 'module.eks.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["Blueprint"]' 'module.eks.aws_ec2_tag.cluster_primary_security_group["Blueprint"]'
terraform state mv 'module.eks.module.aws_eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"]' 'module.eks.aws_ec2_tag.cluster_primary_security_group["GithubRepo"]'

# Cluster security group
terraform state mv 'module.eks.module.aws_eks.aws_security_group.cluster[0]' 'module.eks.aws_security_group.cluster[0]'

# Cluster security group rules
terraform state mv 'module.eks.module.aws_eks.aws_security_group_rule.cluster["ingress_nodes_443"]' 'module.eks.aws_security_group_rule.cluster["ingress_nodes_443"]'

# Node security group
terraform state mv 'module.eks.module.aws_eks.aws_security_group.node[0]' 'module.eks.aws_security_group.node[0]'

# Node security group rules
terraform state mv 'module.eks.module.aws_eks.aws_security_group_rule.node["ingress_cluster_443"]' 'module.eks.aws_security_group_rule.node["ingress_cluster_443"]'
terraform state mv 'module.eks.module.aws_eks.aws_security_group_rule.node["ingress_cluster_kubelet"]' 'module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"]'
terraform state mv 'module.eks.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]' 'module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]'
terraform state mv 'module.eks.module.aws_eks.aws_security_group_rule.node["ingress_self_coredns_udp"]' 'module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"]'

# OIDC provider
terraform state mv 'module.eks.module.aws_eks.aws_iam_openid_connect_provider.oidc_provider[0]' 'module.eks.aws_iam_openid_connect_provider.oidc_provider[0]'

# Fargate profile(s)
# Note: This demonstrates migrating one profile that is stored under the
#       key `fargate` in the module definition. The same set of steps would
#       need to be performed for each profile, changing only the key name
terraform state mv 'module.eks.module.aws_eks_fargate_profiles["fargate"].aws_eks_fargate_profile.eks_fargate' 'module.eks.module.fargate_profile["fargate"].aws_eks_fargate_profile.this[0]'
terraform state mv 'module.eks.module.aws_eks_fargate_profiles["fargate"].aws_iam_role.fargate[0]' 'module.eks.module.fargate_profile["fargate"].aws_iam_role.this[0]'
terraform state mv 'module.eks.module.aws_eks_fargate_profiles["fargate"].aws_iam_role_policy_attachment.fargate_pod_execution_role_policy["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]' 'module.eks.module.fargate_profile["fargate"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]'

# Managed nodegroup(s)
# Note: This demonstrates migrating one nodegroup that is stored under the
#       key `managed` in the module definition. The same set of steps would
#       need to be performed for each nodegroup, changing only the key name
terraform state mv 'module.eks.module.aws_eks_managed_node_groups["managed"].aws_eks_node_group.managed_ng' 'module.eks.module.eks_managed_node_group["managed"].aws_eks_node_group.this[0]'
terraform state mv 'module.eks.module.aws_eks_managed_node_groups["managed"].aws_iam_role.managed_ng[0]' 'module.eks.module.eks_managed_node_group["managed"].aws_iam_role.this[0]'
terraform state mv 'module.eks.module.aws_eks_managed_node_groups["managed"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]' 'module.eks.module.eks_managed_node_group["managed"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]'
terraform state mv 'module.eks.module.aws_eks_managed_node_groups["managed"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]' 'module.eks.module.eks_managed_node_group["managed"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]'
terraform state mv 'module.eks.module.aws_eks_managed_node_groups["managed"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]' 'module.eks.module.eks_managed_node_group["managed"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]'

# Self-managed nodegroup(s)
# Note: This demonstrates migrating one nodegroup that is stored under the
#       key `self_managed` in the module definition. The same set of steps would
#       need to be performed for each nodegroup, changing only the key name
terraform state mv 'module.eks.module.aws_eks_self_managed_node_groups["self_managed"].aws_autoscaling_group.self_managed_ng' 'module.eks.module.self_managed_node_group["self_managed"].aws_autoscaling_group.this[0]'
terraform state mv 'module.eks.module.aws_eks_self_managed_node_groups["self_managed"].aws_iam_instance_profile.self_managed_ng[0]' 'module.eks.module.self_managed_node_group["self_managed"].aws_iam_instance_profile.this[0]'
terraform state mv 'module.eks.module.aws_eks_self_managed_node_groups["self_managed"].aws_iam_role.self_managed_ng[0]' 'module.eks.module.self_managed_node_group["self_managed"].aws_iam_role.this[0]'
terraform state mv 'module.eks.module.aws_eks_self_managed_node_groups["self_managed"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]' 'module.eks.module.self_managed_node_group["self_managed"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]'
terraform state mv 'module.eks.module.aws_eks_self_managed_node_groups["self_managed"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]' 'module.eks.module.self_managed_node_group["self_managed"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]'
terraform state mv 'module.eks.module.aws_eks_self_managed_node_groups["self_managed"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]' 'module.eks.module.self_managed_node_group["self_managed"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]'
terraform state mv 'module.eks.module.aws_eks_self_managed_node_groups["self_managed"].module.launch_template_self_managed_ng.aws_launch_template.this["self-managed-node-group"]' 'module.eks.module.self_managed_node_group["self_managed"].aws_launch_template.this[0]'

# Secrets KMS key
terraform state mv ' module.eks.module.kms[0].aws_kms_key.this' 'module.eks.module.kms.aws_kms_key.this[0]'
terraform state mv 'module.eks.module.kms[0].aws_kms_alias.this' 'module.eks.module.kms.aws_kms_alias.this["migration"]'

# Cloudwatch Log Group
terraform import 'module.eks.aws_cloudwatch_log_group.this[0]' /aws/eks/migration/cluster
```

## Removed Resources

The following resources will be destroyed when migrating from EKS Blueprints v4.32.1 cluster to the v19.x EKS cluster:

```hcl
module.eks.module.aws_eks_managed_node_groups["managed"].aws_iam_instance_profile.managed_ng[0]
```

  - It is not directly used and was intended to be used by Karpenter. The https://github.com/aws-ia/terraform-aws-eks-blueprints-addons module provides its own resource for creating an IAM instance profile for Karpenter

```hcl
module.eks.module.aws_eks_managed_node_groups["managed"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
```

  - IAM policy is not required by EKS - users can re-add this policy at their discretion

```hcl
module.eks.module.aws_eks_fargate_profiles["fargate"].aws_iam_policy.cwlogs[0]
module.eks.module.aws_eks_fargate_profiles["fargate"].aws_iam_role_policy_attachment.cwlogs[0]
```

  - Policy is not required by EKS

```hcl
module.eks.module.aws_eks_self_managed_node_groups["self_managed"].aws_iam_role_policy_attachment.self_managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
```

  - IAM policy is not required by EKS - users can re-add this policy at their discretion
