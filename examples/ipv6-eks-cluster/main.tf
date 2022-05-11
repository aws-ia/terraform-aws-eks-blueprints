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

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  tenant      = "ipv6"    # AWS account name or unique id for tenant
  environment = "preprod" # Environment area eg., preprod or prod
  zone        = "dev"     # Environment with in one sub_tenant or business unit
  region      = "us-west-2"

  vpc_cidr     = "10.0.0.0/16"
  vpc_name     = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.0.1"
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  enable_ipv6                                    = true
  assign_ipv6_address_on_creation                = true # Assign IPv6 address on subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch
  private_subnet_assign_ipv6_address_on_creation = true # Assign IPv6 address on private subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch

  public_subnet_ipv6_prefixes  = [0, 1, 2] # Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list
  private_subnet_ipv6_prefixes = [3, 4, 5] # Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
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
#---------------------------------------------------------------
# Example to consume eks_blueprints module
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # IPV6
  cluster_ip_family = "ipv6"

  # EKS CONTROL PLANE VARIABLES
  cluster_version = "1.21"

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_4 = {
      node_group_name = "mng-ondemand"
      instance_types  = ["m5.large"]
      min_size        = "2"
      desired_size    = "2"
      max_size        = "10"
      subnet_ids      = module.aws_vpc.private_subnets
    }
  }
}

module "eks_blueprints_kubernetes_addons" {
  source         = "../../modules/kubernetes-addons"
  eks_cluster_id = module.eks_blueprints.eks_cluster_id
  enable_ipv6    = true # Enable Ipv6 network. Attaches new VPC CNI policy to the IRSA role

  # EKS Managed Add-ons
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true
  enable_amazon_eks_vpc_cni    = true

  #K8s Add-ons
  enable_aws_load_balancer_controller = true

  depends_on = [module.eks_blueprints.managed_node_groups]
}
