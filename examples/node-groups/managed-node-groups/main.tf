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

#------------------------------------------------------------------------
# Local Variables
#------------------------------------------------------------------------
locals {
  tenant      = var.tenant      # AWS account name or unique id for tenant
  environment = var.environment # Environment area eg., preprod or prod
  zone        = var.zone        # Evironment with in one sub_tenant or business unit
  region      = "us-west-2"

  vpc_cidr                = "10.0.0.0/16"
  vpc_name                = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  count_availability_zone = (length(data.aws_availability_zones.available.names) <= 3) ? length(data.aws_availability_zones.available.zone_ids) : 3
  azs                     = slice(data.aws_availability_zones.available.names, 0, local.count_availability_zone)
  cluster_name            = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.0.1"
}

#------------------------------------------------------------------------
# AWS VPC Module
#------------------------------------------------------------------------
module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

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

#------------------------------------------------------------------------
# AWS EKS Blueprints Module
#------------------------------------------------------------------------
module "eks_blueprints" {
  source = "../../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # Attach additional security group ids to Worker Security group ID
  worker_additional_security_group_ids = [] # Optional

  # EKS CONTROL PLANE VARIABLES
  cluster_version = "1.21"

  # EKS MANAGED NODE GROUPS with minimum config
  managed_node_groups = {
    mg_4 = {
      node_group_name = "mg4"
      instance_types  = ["m4.large"]
      min_size        = "2"
    },
    #---------------------------------------------------------#
    # On-Demand Worker Group with most of the available options
    #---------------------------------------------------------#
    mg_5 = {
      # 1> Node Group configuration - Part1
      node_group_name = "mg5" # Max 40 characters for node group name

      # Launch template configuration
      create_launch_template  = true              # false will use the default launch template
      launch_template_os      = "amazonlinux2eks" # amazonlinux2eks or bottlerocket
      launch_template_id      = null              # Optional
      launch_template_version = "$Latest"         # Optional

      enable_monitoring = true
      eni_delete        = true
      public_ip         = false # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;

      pre_userdata = <<-EOT
            yum install -y amazon-ssm-agent
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent"
        EOT

      post_userdata        = "" # Optional
      kubelet_extra_args   = "" # Optional
      bootstrap_extra_args = "" # Optional

      # 2> Node Group scaling configuration
      desired_size    = 2
      max_size        = 2
      min_size        = 2
      max_unavailable = 1 # or percentage = 20

      # 3> Node Group compute configuration
      ami_type        = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
      release_version = ""           # Enter AMI release version to deploy the latest AMI released by AWS
      capacity_type   = "ON_DEMAND"  # ON_DEMAND or SPOT
      instance_types  = ["m5.large"] # List of instances used only for SPOT type
      disk_size       = 50

      # 4> Node Group network configuration
      subnet_type = "private" # public or private - Default to Private
      subnet_ids  = []        # Defaults to private subnet-ids used by EKS Controle plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']

      additional_iam_policies = [] # Attach additional IAM policies to the IAM role attached to this worker group

      # SSH ACCESS Optional   - Use SSM instead
      remote_access         = false
      ec2_ssh_key           = ""
      ssh_security_group_id = ""

      k8s_taints = []

      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        WorkerType  = "ON_DEMAND"
      }
      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }
      create_worker_security_group = false # Creates a new sec group for this worker group
    }
  }
}

#------------------------------------------------------------------------
# Kubernetes Add-on Module
#------------------------------------------------------------------------
module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  enable_metrics_server     = true
  enable_cluster_autoscaler = true

}
