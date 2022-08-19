# Node Groups

## EKS Managed Node Groups w/ EC2 Spot Instances

We recommend you to use EKS managed node groups when using EC2 Spot instances. EKS managed node groups create an autoscaling group for utilizing Spot best practices.

- Configure the [capacity_rebalance](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-capacity-rebalancing.html) feature to `true`
- Manage the rebalance notification notice by launching a new instance proactively when there's an instance with a high-risk of being interrupted. This is instance is [cordoned](https://jamesdefabia.github.io/docs/user-guide/kubectl/kubectl_cordon/) automatically so no new pods are scheduled there.
- Use [capacity-optimized](https://aws.amazon.com/about-aws/whats-new/2019/08/new-capacity-optimized-allocation-strategy-for-provisioning-amazon-ec2-spot-instances/) allocation strategy to launch an instance from the [pool](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html#spot-features) with more spare capacity
- Manage the instance interruption notice by draining the pods automatically to other nodes in the cluster.

The example below demonstrates the minimum configuration required to deploy a managed node group using EC2 Spot instances. Notice how we're including more than one instance type for diversification purposes. Diversification is key, is how you'll get access to more spare capacity in EC2. You can use the [Amazon EC2 Instance Selector CLI](https://github.com/aws/amazon-ec2-instance-selector) to get a list of instances that match your workload.

```hcl
  spot_2vcpu_8mem = {
    name          = "spot-2vcpu-8mem"
    capacity_type = "SPOT"

    # Instances with same specs for memory and CPU so Cluster Autoscaler scales efficiently
    instance_types  = ["m5.large", "m4.large", "m6a.large", "m5a.large", "m5d.large"]

    # Avoid scheduling stateful workloads in SPOT nodes
    taints = [
      {
        key    = "spotInstance"
        value  = "true"
        effect = "NO_SCHEDULE"
      }
    ]
  }
```

The example below demonstrates advanced configuration options for a managed node group with a custom launch templates. This is important if you decide to add the ability to scale-down to zero nodes. Cluster autoscaler needs to be able to identify which nodes to scale-down, and you do it by adding custom tags.

```hcl
  spot_2vcpu_8mem = {
    name = "spot-2vcpu-8mem"

    capacity_type   = "SPOT"

    # Scale-down to zero nodes when no workloads are running, useful for pre-production environments
    min_size = 0

    # Instances with same specs for memory and CPU
    instance_types  = ["m5.large", "m4.large", "m6a.large", "m5a.large", "m5d.large"]

    # Avoid scheduling stateful workloads in SPOT nodes
    taints = [
      {
        key    = "spotInstance"
        value  = "true"
        effect = "NO_SCHEDULE"
      }
    ]

    # This is so cluster autoscaler can identify which node (using ASGs tags) to scale-down to zero nodes
    additional_tags = {
      "k8s.io/cluster-autoscaler/node-template/label/eks.amazonaws.com/capacityType" = "SPOT"
      "k8s.io/cluster-autoscaler/node-template/label/eks/node_group_name"            = "spot-2vcpu-8mem"
    }
  }
```

Cluster autoscaler has the ability to set priorities on which node groups to scale by using the `priority` expander. To configure it, you need to add the following configuration in the `eks_blueprints_kubernetes_addons` block, like this:

```hcl
  enable_cluster_autoscaler = true
  cluster_autoscaler_helm_config = {
    set = [
      {
        name  = "extraArgs.expander"
        value = "priority"
      },
      {
        name  = "expanderPriorities"
        value = <<-EOT
          100:
            - .*-spot-2vcpu-8mem.*
          90:
            - .*-spot-4vcpu-16mem.*
          10:
            - .*
        EOT
      }
    ]
  }
```

## Self-Managed Node Groups w/ EC2 Spot Instances

We recommend you to use managed-node groups (MNG) when using EC2 Spot instances. However, if you need to use self-managed node groups, you need to configure the ASG with the following Spot best practices:

- Configure the [capacity_rebalance](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-capacity-rebalancing.html) feature to `true`
- Use the [capacity-optimized](https://aws.amazon.com/about-aws/whats-new/2019/08/new-capacity-optimized-allocation-strategy-for-provisioning-amazon-ec2-spot-instances/) allocation strategy to launch an instance from the [pool](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html#spot-features) with more spare capacity
- Deploy the [Node Termination Handler (NTH)](https://github.com/aws/aws-node-termination-handler) to manage the rebalance recommendation and instance termination notice

The example below demonstrates the minimum configuration required to deploy a self-managed node group. Notice how we're including more than one instance type for diversification purposes. Diversification is key; its how you'll get access to more spare capacity in EC2. You can use the [Amazon EC2 Instance Selector CLI](https://github.com/aws/amazon-ec2-instance-selector) to get a list of instances that match your workload.

```hcl
  spot_2vcpu_8mem = {
    name = "spot-2vcpu-8mem"

    capacity_type      = "spot"
    capacity_rebalance = true
    instance_types     = ["m5.large", "m4.large", "m6a.large", "m5a.large", "m5d.large"]
    min_size           = 0

    taints = [
      {
        key    = "spotInstance"
        value  = "true"
        effect = "NO_SCHEDULE"
      }
    ]
  }
```

You need to deploy the NTH as an add-on, so make sure you include the following within the `eks_blueprints_kubernetes_addons` block:

```hcl
  auto_scaling_group_names = module.eks_blueprints.self_managed_node_group_autoscaling_groups
  enable_aws_node_termination_handler = true
```

Cluster autoscaler has the ability to set priorities on which node groups to scale by using the `priority` expander. To configure it, you need to add the following configuration in the `eks_blueprints_kubernetes_addons` block, like this:

```hcl
  enable_cluster_autoscaler = true
  cluster_autoscaler_helm_config = {
    set = [
      {
        name  = "extraArgs.expander"
        value = "priority"
      },
      {
        name  = "expanderPriorities"
        value = <<-EOT
                  100:
                    - .*-spot-2vcpu-8mem.*
                  90:
                    - .*-spot-4vcpu-16mem.*
                  10:
                    - .*
                EOT
      }
    ]
  }
```

## Additional IAM Roles, Users and Accounts

Access to EKS cluster using AWS IAM entities is enabled by the [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) for Kubernetes, which runs on the Amazon EKS control plane.
The authenticator gets its configuration information from the `aws-auth` [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/).

The following config grants additional AWS IAM users or roles the ability to interact with your cluster. However, the best practice is to leverage [soft multi-tenancy](https://aws.github.io/aws-eks-best-practices/security/docs/multitenancy/) with the help of [Teams](teams.md) module. Teams feature helps to manage users with dedicated namespaces, RBAC, IAM roles and register users with `aws-auth` to provide access to the EKS Cluster.

The example below demonstrates adding additional IAM Roles, IAM Users and Accounts using EKS Blueprints module

```hcl
module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  # Parameters truncated for brevity ...

  map_roles          = [
    {
      rolearn  = "arn:aws:iam::<aws-account-id>:role/<role-name>"
      username = "ops-role"         # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"] # Kubernetes groups that are mapped to the role; See Kubernetes Role and Rolebindings
    }
  ]

  map_users = [
    {
      userarn  = "arn:aws:iam::<aws-account-id>:user/<username>"
      username = "opsuser"          # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"] # Kubernetes groups that are mapped to the role; See Kubernetes Role and Rolebindings
    }
  ]

  map_accounts = ["123456789", "9876543321"]
}
```
