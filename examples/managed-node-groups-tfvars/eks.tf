#------------------------------------------------------------------------
# AWS VPC Module
#------------------------------------------------------------------------
module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.12.0"

  name = local.vpc_name
  cidr = var.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

#------------------------------------------------------------------------
# AWS EKS Accelerator Module
#------------------------------------------------------------------------
module "aws-eks-accelerator-for-terraform" {
  # source = "github.com/aws-samples/aws-eks-accelerator-for-terraform?ref=v3.5.0"
  source = "../../"

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS MANAGED NODE GROUPS with minimum config
  managed_node_groups = var.managed_node_groups
}
