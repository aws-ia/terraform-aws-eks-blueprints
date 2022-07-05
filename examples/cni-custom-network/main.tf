provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}


data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"
  
  vpc_id          = "vpc-037cb35203764ffad"
  private_subnets = ["subnet-0442dc7e2432195d1", "subnet-04b36bcdae75ec8b8", "subnet-07bfd66baf3d4c586"]
  pod_subnets     = ["subnet-0c219efb123adb6c9", "subnet-01ffcaebc7b8d646a", "subnet-03ca795535d591db9"]
  
  map_users = [
    {
      userarn  = "arn:aws:iam::776765247973:user/qtruon-su"
      username = "adminruser"
      groups   = ["system:masters"]
    }
  ]

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../.."

  cluster_name    = local.name
  cluster_version = "1.21"

  vpc_id             = local.vpc_id
  private_subnet_ids = local.private_subnets
  pod_subnet_ids     = local.pod_subnets
  
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

#   managed_node_groups = {
#     mg_5 = {
#       node_group_name = "managed-ondemand"
#       instance_types  = ["m3.medium"]
#       subnet_ids      = local.private_subnets
#     }
#   }
  
  self_managed_node_groups = {
    self_mg4 = {
      node_group_name    = "self_mg4"
      launch_template_os = "amazonlinux2eks"
      subnet_ids         = local.private_subnets
    }
  }
  
  map_users = local.map_users

  tags = local.tags
}

output "kubeconfig" {
  value = module.eks_blueprints.configure_kubectl
}