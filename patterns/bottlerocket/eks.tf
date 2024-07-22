################################################################################
# EKS Cluster
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.20"

  cluster_name                   = local.name
  cluster_version                = "1.30"
  cluster_endpoint_public_access = true

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }
  # Give the Terraform identity admin access to the cluster
  # which will allow resources to be deployed into the cluster
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API"

  eks_managed_node_groups = {
    bottlerocket = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["m5.large", "m5a.large"]

      iam_role_attach_cni_policy = true
      # The below AMI release version is for testing purposes in order to validate Botterocket Update Operator.
      ami_release_version = "1.20.0-fcf71a47"

      min_size     = 1
      max_size     = 5
      desired_size = 3

      ebs_optimized     = true
      enable_monitoring = true
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            encrypted             = true
            kms_key_id            = module.ebs_kms_key.key_arn
            delete_on_termination = true
          }
        }
        xvdb = {
          device_name = "/dev/xvdb"
          ebs = {
            encrypted             = true
            kms_key_id            = module.ebs_kms_key.key_arn
            delete_on_termination = true
          }
        }
      }

      # The following block customize your Bottlerocket instances, including kubernetes tags, host and kernel parameters, and user-data.
      bootstrap_extra_args = <<-EOT
            [settings.host-containers.admin]
            enabled = false

            [settings.host-containers.control]
            enabled = true

            [settings.kernel]
            lockdown = "integrity"

            [settings.kubernetes.node-labels]
            "bottlerocket.aws/updater-interface-version" = "2.0.0"

            [settings.kubernetes.node-taints]
            "CriticalAddonsOnly" = "true:NoSchedule"
          EOT
    }
  }

  tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.name
  })
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.5"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    module.eks.cluster_iam_role_arn,
    module.eks_blueprints_addons.karpenter.iam_role_arn
  ]

  aliases = ["eks/${local.name}/ebs"]

  tags = local.tags
}
