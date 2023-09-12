provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

################################################################################
# Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = local.name
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true
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

  tags = local.tags
}
