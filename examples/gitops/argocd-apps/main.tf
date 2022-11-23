
data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_availability_zones" "available" {}
 
module "eks_blueprints" {
  source = "../terraform-aws-eks-blueprints1"

  # EKS CLUSTER
  cluster_name             = "gymops"
  cluster_version          = "1.23"
  vpc_id                   = "vpc-099f541c1e0355870"                                  # Enter VPC ID
  public_subnet_ids        = ["subnet-0d29af39329819d69", "subnet-0f72d078e790654e3"] # Enter Private Subnet IDs
  control_plane_subnet_ids = ["subnet-0d29af39329819d69", "subnet-0f72d078e790654e3"]

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    t2_medium = {
      node_group_name = "t2_on_demand" # Max node group length is 40 characters; including the node_group_name_prefix random id it's 63
      instance_types  = ["t3.medium"]
      subnet_ids      = ["subnet-0d29af39329819d69", "subnet-0f72d078e790654e3"]
    }
  }
}

module "eks_blueprints_kubernetes_addons" {
  source = "../terraform-aws-eks-blueprints1/modules/kubernetes-addons"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  enable_argocd = true
  enable_argocd_application = true
  argocd_application_helm_config = {
	repository                 = var.chart_repository
	version                    = var.chart_version
#	values = ["${file("values.yaml")}"]
	set = [
      {
        name  = "applications.source.repoUrl"
        value = var.github_repository_url
      },
      {
	      name  = "applications.source.path"
	      value = var.var.github_directory_path 
      }
    ]
  }
}
