#------------------------------------------------------------------------
# Terraform Provider Versions
#------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }

  backend "local" {
    path = "local_tf_state/terraform-main.tfstate"
  }
}

#------------------------------------------------------------------------
# Terraform Providers
#------------------------------------------------------------------------
provider "aws" {}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

#------------------------------------------------------------------------
# Data Resources
#------------------------------------------------------------------------
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks-blueprints.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-blueprints.eks_cluster_id
}

data "aws_ami" "amazonlinux2eks" {
  most_recent = true
  filter {
    name   = "name"
    values = [local.amazonlinux2eks]
  }
  owners = ["amazon"]
}

#------------------------------------------------------------------------
# Local Variables
#------------------------------------------------------------------------
locals {
  tenant          = var.tenant      # AWS account name or unique id for tenant
  environment     = var.environment # Environment area eg., preprod or prod
  zone            = var.zone        # Environment with in one sub_tenant or business unit
  cluster_version = var.cluster_version

  vpc_cidr                = "10.0.0.0/16"
  vpc_name                = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  count_availability_zone = (length(data.aws_availability_zones.available.names) <= 3) ? length(data.aws_availability_zones.available.zone_ids) : 3
  azs                     = slice(data.aws_availability_zones.available.names, 0, local.count_availability_zone)
  cluster_name            = join("-", [local.tenant, local.environment, local.zone, "eks"])
  amazonlinux2eks         = "amazon-eks-node-${var.cluster_version}-*"

  terraform_version = "Terraform v1.0.1"
}

#------------------------------------------------------------------------
# AWS VPC Module
#------------------------------------------------------------------------
module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.2.0"

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
module "eks-blueprints" {
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
  cluster_version = local.cluster_version

  #----------------------------------------------------------------------------------------------------------#
  # Security groups used in this module created by the upstream modules terraform-aws-eks (https://github.com/terraform-aws-modules/terraform-aws-eks).
  #   Upstream module implemented Security groups based on the best practices doc https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html.
  #   So, by default the security groups are restrictive. Users needs to enable rules for specific ports required for App requirement or Add-ons
  #   See the notes below for each rule used in these examples
  #----------------------------------------------------------------------------------------------------------#
  node_security_group_additional_rules = {
    # Extend node-to-node security group rules. Recommended and required for the Add-ons
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    #Recommended outbound traffic for Node groups
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    # Allows Control Plane Nodes to talk to Worker nodes on all ports. Added this to simplify the example and further avoid issues with Add-ons communication with Control plane.
    # This can be restricted further to specific port based on the requirement for each Add-on e.g., metrics-server 4443, spark-operator 8080, karpenter 8443 etc.
    # Change this according to your security requirements if needed
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    # Managed Node groups with minimum config
    mg5 = {
      node_group_name = "mg5"
      instance_types  = ["m5.large"]
      min_size        = "2"
      disk_size       = 100 # Disk size is used only with Managed Node Groups without Launch Templates
    },
    # Managed Node groups with Launch templates using AMI TYPE
    mng_lt = {
      # Node Group configuration
      node_group_name = "mng_lt" # Max 40 characters for node group name

      ami_type        = "AL2_x86_64" # Available options -> AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
      release_version = ""           # Enter AMI release version to deploy the latest AMI released by AWS. Used only when you specify ami_type
      capacity_type   = "ON_DEMAND"  # ON_DEMAND or SPOT
      instance_types  = ["m5.large"] # List of instances used only for SPOT type

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      enable_monitoring = true
      eni_delete        = true
      public_ip         = false # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates

      # pre_userdata can be used in both cases where you provide custom_ami_id or ami_type
      pre_userdata = <<-EOT
            yum install -y amazon-ssm-agent
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
        EOT

      # Taints can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      # e.g., k8s_taints = [{key= "spot", value="true", "effect"="NO_SCHEDULE"}]
      k8s_taints = []

      # Node Labels can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        Runtime     = "docker"
      }

      # Node Group scaling configuration
      desired_size    = 2
      max_size        = 2
      min_size        = 2
      max_unavailable = 1 # or percentage = 20

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 100
        }
      ]

      # Node Group network configuration
      subnet_type = "private" # public or private - Default uses the private subnets used in control plane if you don't pass the "subnet_ids"
      subnet_ids  = []        # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']

      additional_iam_policies = [] # Attach additional IAM policies to the IAM role attached to this worker group

      # SSH ACCESS Optional - Recommended to use SSM Session manager
      remote_access         = false
      ec2_ssh_key           = ""
      ssh_security_group_id = ""

      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }
    }
    # Managed Node groups with Launch templates using CUSTOM AMI with ContainerD runtime
    mng_custom_ami = {
      # Node Group configuration
      node_group_name = "mng_custom_ami" # Max 40 characters for node group name

      # custom_ami_id is optional when you provide ami_type. Enter the Custom AMI id if you want to use your own custom AMI
      custom_ami_id  = data.aws_ami.amazonlinux2eks.id
      capacity_type  = "ON_DEMAND"  # ON_DEMAND or SPOT
      instance_types = ["m5.large"] # List of instances used only for SPOT type

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket

      # pre_userdata will be applied by using custom_ami_id or ami_type
      pre_userdata = <<-EOT
            yum install -y amazon-ssm-agent
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
        EOT

      # post_userdata will be applied only by using custom_ami_id
      post_userdata = <<-EOT
            echo "Bootstrap successfully completed! You can further apply config or install to run after bootstrap if needed"
      EOT

      # kubelet_extra_args used only when you pass custom_ami_id;
      # --node-labels is used to apply Kubernetes Labels to Nodes
      # --register-with-taints used to apply taints to Nodes
      # e.g., kubelet_extra_args='--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=spot=true:NoSchedule --max-pods=58',
      kubelet_extra_args = "--node-labels=WorkerType=SPOT,noderole=spark --register-with-taints=test=true:NoSchedule --max-pods=20"

      # bootstrap_extra_args used only when you pass custom_ami_id. Allows you to change the Container Runtime for Nodes
      # e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
      bootstrap_extra_args = "--use-max-pods false --container-runtime containerd"

      # Taints can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      k8s_taints = []

      # Node Labels can be applied through EKS API or through Bootstrap script using kubelet_extra_args
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        Runtime     = "containerd"
      }

      enable_monitoring = true
      eni_delete        = true
      public_ip         = false # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates

      # Node Group scaling configuration
      desired_size    = 2
      max_size        = 2
      min_size        = 2
      max_unavailable = 1 # or percentage = 20

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 150
        }
      ]

      # Node Group network configuration
      subnet_type = "private" # public or private - Default uses the private subnets used in control plane if you don't pass the "subnet_ids"
      subnet_ids  = []        # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']

      additional_iam_policies = [] # Attach additional IAM policies to the IAM role attached to this worker group

      # SSH ACCESS Optional - Recommended to use SSM Session manager
      remote_access         = false
      ec2_ssh_key           = ""
      ssh_security_group_id = ""

      additional_tags = {
        ExtraTag    = "mng-custom-ami"
        Name        = "mng-custom-ami"
        subnet_type = "private"
      }
    }
  }
}

#------------------------------------------------------------------------
# Kubernetes Add-on Module
#------------------------------------------------------------------------
module "eks-blueprints-kubernetes-addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id = module.eks-blueprints.eks_cluster_id

  enable_metrics_server     = true
  enable_cluster_autoscaler = true

}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks-blueprints.configure_kubectl
}
