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
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.aws-eks-accelerator-for-terraform.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.aws-eks-accelerator-for-terraform.eks_cluster_id
}

provider "aws" {
  region = data.aws_region.current.id
  alias  = "default"
}

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

locals {
  tenant      = "aws001"  # AWS account name or unique id for tenant
  environment = "preprod" # Environment area eg., preprod or prod
  zone        = "dev"     # Environment with in one sub_tenant or business unit

  kubernetes_version = "1.21"

  vpc_cidr     = "10.0.0.0/16"
  vpc_name     = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.0.1"
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.2.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = data.aws_availability_zones.available.names

  public_subnets  = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k + 10)]

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
# Example to consume aws-eks-accelerator-for-terraform module
#---------------------------------------------------------------
module "aws-eks-accelerator-for-terraform" {
  source = "../../../../../../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  kubernetes_version = local.kubernetes_version
  #---------------------------------------------------------#
  # EKS WORKER NODE GROUPS
  # Define Node groups as map of maps object as shown below. Each node group creates the following
  #    1. New node group
  #    2. IAM role and policies for Node group
  #    3. Security Group for Node group (Optional)
  #    4. Launch Templates for Node group   (Optional)
  #---------------------------------------------------------#
  managed_node_groups = {
    #---------------------------------------------------------#
    # ON-DEMAND Worker Group - Worker Group - 1
    #---------------------------------------------------------#
    mg_4 = {
      # 1> Node Group configuration - Part1
      node_group_name        = "managed-ondemand" # Max 40 characters for node group name
      create_launch_template = true               # false will use the default launch template
      launch_template_os     = "amazonlinux2eks"  # amazonlinux2eks or bottlerocket
      public_ip              = false              # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata           = <<-EOT
            yum install -y amazon-ssm-agent
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent"
        EOT
      # 2> Node Group scaling configuration
      desired_size    = 3
      max_size        = 3
      min_size        = 3
      max_unavailable = 1 # or percentage = 20

      # 3> Node Group compute configuration
      ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
      capacity_type  = "ON_DEMAND"  # ON_DEMAND or SPOT
      instance_types = ["m4.large"] # List of instances used only for SPOT type
      disk_size      = 50

      # 4> Node Group network configuration
      subnet_ids = module.aws_vpc.private_subnets # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

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
      create_worker_security_group = true
    },
    #---------------------------------------------------------#
    # SPOT Worker Group - Worker Group - 2
    #---------------------------------------------------------#
    /*
    spot_m5 = {
      # 1> Node Group configuration - Part1
      node_group_name        = "managed-spot-m5"
      create_launch_template = true              # false will use the default launch template
      launch_template_os        = "amazonlinux2eks" # amazonlinux2eks  or bottlerocket
      public_ip              = false             # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata           = <<-EOT
                 yum install -y amazon-ssm-agent
                 systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent"
             EOT

      # Node Group scaling configuration
      desired_size = 3
      max_size     = 3
      min_size     = 3

      # Node Group update configuration. Set the maximum number or percentage of unavailable nodes to be tolerated during the node group version update.
      max_unavailable = 1 # or percentage = 20

      # Node Group compute configuration
      ami_type       = "AL2_x86_64"
      capacity_type  = "SPOT"
      instance_types = ["t3.medium", "t3a.medium"]
      disk_size      = 50

      # Node Group network configuration

      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = []

      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        WorkerType  = "SPOT"
      }
      additional_tags = {
        ExtraTag    = "spot_nodes"
        Name        = "spot"
        subnet_type = "private"
      }

      create_worker_security_group = false
    },
    #---------------------------------------------------------#
    # BOTTLEROCKET - Worker Group - 3
    #---------------------------------------------------------#
    brkt_m5 = {
      node_group_name        = "managed-brkt-m5"
      create_launch_template = true           # false will use the default launch template
      launch_template_os        = "bottlerocket" # amazonlinux2eks  or bottlerocket
      public_ip              = false          # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata           = ""

      desired_size    = 3
      max_size        = 3
      min_size        = 3
      max_unavailable = 1

      ami_type       = "CUSTOM"
      capacity_type  = "ON_DEMAND" # ON_DEMAND or SPOT
      instance_types = ["m5.large"]
      disk_size      = 50
      custom_ami_id  = "ami-044b114caf98ce8c5" # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami-bottlerocket.html

      # Node Group network configuration

      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_taints = []
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        OS          = "bottlerocket"
        WorkerType  = "ON_DEMAND_BOTTLEROCKET"
      }
      additional_tags = {
        ExtraTag = "bottlerocket"
        Name     = "bottlerocket"
      }
      #security_group ID
      create_worker_security_group = true
    }
      */
  } # END OF MANAGED NODE GROUPS

  #---------------------------------------------------------#
  # EKS SELF MANAGED WORKER NODE GROUPS
  #---------------------------------------------------------#

  enable_windows_support = false
  self_managed_node_groups = {
    #---------------------------------------------------------#
    # ON-DEMAND Self Managed Worker Group - Worker Group - 1
    #---------------------------------------------------------#
    self_mg_4 = {
      node_group_name        = "self-managed-ondemand" # Name is used to create a dedicated IAM role for each node group and adds to AWS-AUTH config map
      create_launch_template = true
      launch_template_os     = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
      custom_ami_id          = "ami-0dfaa019a300f219c" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
      public_ip              = false                   # Enable only for public subnets
      pre_userdata           = <<-EOT
            yum install -y amazon-ssm-agent \
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent \
        EOT

      block_device_mapping = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 20
        }
      ]
      instance_type = "m5.large"

      desired_size = 2
      max_size     = 10
      min_size     = 2

      capacity_type = "" # Optional Use this only for SPOT capacity as  capacity_type = "spot"

      k8s_labels = {
        Environment = "preprod"
        Zone        = "test"
        WorkerType  = "SELF_MANAGED_ON_DEMAND"
      }

      additional_tags = {
        ExtraTag    = "m5x-on-demand"
        Name        = "m5x-on-demand"
        subnet_type = "private"
      }

      subnet_ids                   = []    # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']
      create_worker_security_group = false # Creates a dedicated sec group for this Node Group
    },
    /*
    spot_m5 = {
      # 1> Node Group configuration - Part1
      node_group_name = "self-managed-spot"
      create_launch_template = true
      launch_template_os = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
      custom_ami_id   = "ami-0dfaa019a300f219c" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
      public_ip       = false                   # Enable only for public subnets
      pre_userdata    = <<-EOT
              yum install -y amazon-ssm-agent \
              systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent \
          EOT

      block_device_mapping = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 20
        }
      ]
      instance_type = "m5.large"

      desired_size = 2
      max_size     = 10
      min_size     = 2

      capacity_type = "spot"

      # Node Group network configuration

      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        WorkerType  = "SPOT"
      }
      additional_tags = {
        ExtraTag    = "spot_nodes"
        Name        = "spot"
        subnet_type = "private"
      }
      create_worker_security_group = false
    },

    brkt_m5 = {
      node_group_name = "self-managed-brkt"
      create_launch_template = true
      launch_template_os = "bottlerocket"          # amazonlinux2eks  or bottlerocket or windows
      custom_ami_id   = "ami-044b114caf98ce8c5" # Bring your own custom AMI generated by Packer/ImageBuilder/Puppet etc.
      public_ip       = false                   # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      pre_userdata    = ""

      desired_size    = 3
      max_size        = 3
      min_size        = 3
      max_unavailable = 1

      instance_types = "m5.large"
      block_device_mapping = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 50
        }
      ]


      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        OS          = "bottlerocket"
        WorkerType  = "ON_DEMAND_BOTTLEROCKET"
      }
      additional_tags = {
        ExtraTag = "bottlerocket"
        Name     = "bottlerocket"
      }
      create_worker_security_group = true
    }
    #---------------------------------------------------------#
    # ON-DEMAND Self Managed Windows Worker Node Group
    #---------------------------------------------------------#
    windows_od = {
      node_group_name = "windows-ondemand"
      create_launch_template = true
      launch_template_os = "windows"          # amazonlinux2eks  or bottlerocket or windows
      # custom_ami_id   = "ami-xxxxxxxxxxxxxxxx" # Bring your own custom AMI. Default Windows AMI is the latest EKS Optimized Windows Server 2019 English Core AMI.
      public_ip = false # Enable only for public subnets

      disk_size     = 50
      instance_type = "m5n.large"

      desired_size = 2
      max_size     = 4
      min_size     = 2

      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        WorkerType  = "WINDOWS_ON_DEMAND"
      }

      additional_tags = {
        ExtraTag    = "windows-on-demand"
        Name        = "windows-on-demand"
      }

      subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']
      create_worker_security_group = false # Creates a dedicated sec group for this Node Group
    }
  */
  } # END OF SELF MANAGED NODE GROUPS
  #---------------------------------------------------------#
  # FARGATE PROFILES
  #---------------------------------------------------------#
  fargate_profiles = {
    default = {
      fargate_profile_name = "default"
      fargate_profile_namespaces = [{
        namespace = "default"
        k8s_labels = {
          Environment = "preprod"
          Zone        = "dev"
          env         = "fargate"
        }
      }]

      subnet_ids = [] # Provide list of private subnets

      additional_tags = {
        ExtraTag = "Fargate"
      }
    },
    /*
    multi = {
      fargate_profile_name = "multi-namespaces"
      fargate_profile_namespaces = [{
        namespace = "default"
        k8s_labels = {
          Environment = "preprod"
          Zone        = "dev"
          OS          = "Fargate"
          WorkerType  = "FARGATE"
          Namespace   = "default"
        }
        },
        {
          namespace = "sales"
          k8s_labels = {
            Environment = "preprod"
            Zone        = "dev"
            OS          = "Fargate"
            WorkerType  = "FARGATE"
            Namespace   = "default"
          }
      }]

      subnet_ids = [] # Provide list of private subnets

      additional_tags = {
        ExtraTag = "Fargate"
      }
    }, */
  } # END OF FARGATE PROFILES
}

module "kubernetes-addons" {
  source = "../../../../../../../modules/kubernetes-addons"

  eks_cluster_id               = module.aws-eks-accelerator-for-terraform.eks_cluster_id
  eks_worker_security_group_id = module.aws-eks-accelerator-for-terraform.worker_security_group_id
  auto_scaling_group_names     = module.aws-eks-accelerator-for-terraform.self_managed_node_group_autoscaling_groups

  # EKS Addons
  enable_amazon_eks_vpc_cni = true # default is false
  #Optional
  amazon_eks_vpc_cni_config = {
    addon_name               = "vpc-cni"
    addon_version            = "v1.10.1-eksbuild.1"
    service_account          = "aws-node"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }

  enable_amazon_eks_coredns = true # default is false
  #Optional
  amazon_eks_coredns_config = {
    addon_name               = "coredns"
    addon_version            = "v1.8.4-eksbuild.1"
    service_account          = "coredns"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = ""
    additional_iam_policies  = []
    tags                     = {}
  }

  enable_amazon_eks_kube_proxy = true # default is false
  #Optional
  amazon_eks_kube_proxy_config = {
    addon_name               = "kube-proxy"
    addon_version            = "v1.21.2-eksbuild.2"
    service_account          = "kube-proxy"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }

  enable_amazon_eks_aws_ebs_csi_driver = true # default is false
  #Optional
  amazon_eks_aws_ebs_csi_driver_config = {
    addon_name               = "aws-ebs-csi-driver"
    addon_version            = "v1.4.0-eksbuild.preview"
    service_account          = "ebs-csi-controller-sa"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }
  #---------------------------------------
  # AWS LOAD BALANCER INGRESS CONTROLLER HELM ADDON
  #---------------------------------------
  enable_aws_load_balancer_controller = true
  # Optional
  aws_load_balancer_controller_helm_config = {
    name       = "aws-load-balancer-controller"
    chart      = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    version    = "1.3.1"
    namespace  = "kube-system"
  }
}
