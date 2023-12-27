provider "kubernetes" {
  alias                  = "k8s-az3"
  host                   = module.eks_az3.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_az3.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_az3.cluster_name]
  }
}

provider "helm" {
  alias = "helm-az3"
  kubernetes {
    host                   = module.eks_az3.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_az3.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_az3.cluster_name]
    }
  }
}

locals {
  cell3_name = format("%s-%s", local.name, "az3")
}

################################################################################
# Cluster
################################################################################

module "eks_az3" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.18"

  providers = {
    kubernetes = kubernetes.k8s-az3
  }

  cluster_name                   = local.cell3_name
  cluster_version                = "1.28"
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    {
      rolearn  = module.eks_blueprints_addons_az3.karpenter.node_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]

  eks_managed_node_groups = {
    cell1 = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 5
      desired_size = 2

      subnet_ids = [module.vpc.private_subnets[2]]
    }
  }

  tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.cell3_name
  })
}

################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_addons_az3" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.11"

  providers = {
    helm       = helm.helm-az3
    kubernetes = kubernetes.k8s-az3
  }

  cluster_name      = module.eks_az3.cluster_name
  cluster_endpoint  = module.eks_az3.cluster_endpoint
  cluster_version   = module.eks_az3.cluster_version
  oidc_provider_arn = module.eks_az3.oidc_provider_arn

  # We want to wait for the EKS Managed Nodegroups to be deployed first
  create_delay_dependencies = [for group in module.eks_az3.eks_managed_node_groups : group.node_group_arn]

  eks_addons = {
    coredns    = {}
    vpc-cni    = {}
    kube-proxy = {}
  }

  enable_karpenter = true
  karpenter = {
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
  }
  karpenter_node = {
    # Use static name so that it matches what is defined in `az3.yaml` example manifest
    iam_role_use_name_prefix = false
  }

  tags = local.tags
}
