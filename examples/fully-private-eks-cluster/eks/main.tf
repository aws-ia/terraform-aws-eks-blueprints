provider "aws" {
  region = var.region
  alias  = "default"
}

provider "kubernetes" {
  host                   = module.eks_blueprints.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.cluster_id
}

locals {
  name = basename(path.cwd)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

module "eks_blueprints" {
  source = "../../.."

  cluster_name    = local.name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  cluster_endpoint_public_access          = false
  cluster_endpoint_private_access         = true

  eks_managed_node_groups = {
    mg_5 = {
      name           = "managed-ondemand"
      instance_types = ["m5.large"]
    }
  }

  tags = local.tags
}
