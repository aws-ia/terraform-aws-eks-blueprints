provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_id]
  }
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1"

  cluster_name    = local.name
  cluster_version = "1.27"

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

  tags = local.tags
}
