/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#---------------------------------------------------------#
# EKS CLUSTER CORE VARIABLES
#---------------------------------------------------------#
#Following fields used in tagging resources and building the name of the cluster
#e.g., eks cluster name will be {tenant}-{environment}-{zone}-{resource}
#---------------------------------------------------------#
org               = "aws"     # Organization Name. Used to tag resources
tenant            = "aws001"  # AWS account name or unique id for tenant
environment       = "preprod" # Environment area eg., preprod or prod
zone              = "dev"     # Environment with in one sub_tenant or business unit
terraform_version = "Terraform v1.0.1"
#---------------------------------------------------------#
# VPC and PRIVATE SUBNET DETAILS for EKS Cluster
#---------------------------------------------------------#
#This provides two options Option1 and Option2. You should choose either of one to provide VPC details to the EKS cluster
#Option1: Creates a new VPC, private Subnets and VPC Endpoints by taking the inputs of vpc_cidr_block and private_subnets_cidr. VPC Endpoints are S3, SSM , EC2, ECR API, ECR DKR, KMS, CloudWatch Logs, STS, Elastic Load Balancing, Autoscaling
#Option2: Provide an existing vpc_id and private_subnet_ids

#---------------------------------------------------------#
# OPTION 1
#---------------------------------------------------------#
create_vpc             = true
enable_private_subnets = true
enable_public_subnets  = true

# Enable or Disable NAT Gateway and Internet Gateway for Public Subnets
enable_nat_gateway = true
single_nat_gateway = true
create_igw         = true

vpc_cidr_block       = "10.1.0.0/18"
private_subnets_cidr = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
public_subnets_cidr  = ["10.1.12.0/22", "10.1.16.0/22", "10.1.20.0/22"]

# Change this to true when you want to create VPC endpoints for Private subnets
create_vpc_endpoints = true
#---------------------------------------------------------#
# OPTION 2
#---------------------------------------------------------#
# create_vpc = false
# vpc_id = "xxxxxx"
# private_subnet_ids = ['xxxxxx','xxxxxx','xxxxxx']
# public_subnet_ids = ['xxxxxx','xxxxxx','xxxxxx']

#---------------------------------------------------------#
# EKS CONTROL PLANE VARIABLES
# API server endpoint access options
#   Endpoint public access: true    - Your cluster API server is accessible from the internet. You can, optionally, limit the CIDR blocks that can access the public endpoint.
#   Endpoint private access: true   - Kubernetes API requests within your cluster's VPC (such as node to control plane communication) use the private VPC endpoint.
#---------------------------------------------------------#
create_eks              = true
kubernetes_version      = "1.20"
endpoint_private_access = true
endpoint_public_access  = true

# Enable IAM Roles for Service Accounts (IRSA) on the EKS cluster
enable_irsa = true

enabled_cluster_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_period = 7

enable_vpc_cni_addon  = true
vpc_cni_addon_version = "v1.8.0-eksbuild.1"

enable_coredns_addon  = true
coredns_addon_version = "v1.8.3-eksbuild.1"

enable_kube_proxy_addon  = true
kube_proxy_addon_version = "v1.20.4-eksbuild.2"


#---------------------------------------------------------#
# EKS SELF MANAGED WORKER NODE GROUPS
#---------------------------------------------------------#
enable_self_managed_nodegroups = true
self_managed_node_groups = {
  #---------------------------------------------------------#
  # ON-DEMAND Self Managed Worker Group - Worker Group - 1
  #---------------------------------------------------------#
  self_mg_4 = {
    self_managed_nodegroup_name     = "self-mg-4"
    os_ami_type                     = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
    self_managed_node_ami_id        = "ami-0dfaa019a300f219c" # Modify this to fetch to use custom AMI ID.
    self_managed_node_userdata      = <<-EOT
            yum install -y amazon-ssm-agent \
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent \
        EOT
    self_managed_node_volume_size   = "20"
    self_managed_node_instance_type = "m5.large"
    self_managed_node_desired_size  = "2"
    self_managed_node_max_size      = "20"
    self_managed_node_min_size      = "2"
    capacity_type                   = "" # Leave this empty if not for SPOT capacity.
    kubelet_extra_args              = ""
    bootstrap_extra_args            = ""

    #self managed node group network configuration
    subnet_type = "public" # private or public
    subnet_ids  = []

    #security_group ID
    self_managed_custom_security_group_id = "" # Add custom sec group id if required from intended vpc or module creates new one.

  },

  #---------------------------------------------------------#
  # Self Managed SPOT Worker Group - Worker Group - 2
  #---------------------------------------------------------#
  self_spot_mg_4 = {
    self_managed_nodegroup_name     = "self-spot-mg-4"
    os_ami_type                     = "amazonlinux2eks"       # amazonlinux2eks  or bottlerocket or windows
    self_managed_node_ami_id        = "ami-0dfaa019a300f219c" # Modify this to fetch to use custom AMI ID.
    self_managed_node_userdata      = <<-EOT
            yum install -y amazon-ssm-agent \
            systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent \
        EOT
    self_managed_node_volume_size   = "20"
    self_managed_node_instance_type = "m5.xlarge"
    self_managed_node_desired_size  = "2"
    self_managed_node_max_size      = "20"
    self_managed_node_min_size      = "2"
    capacity_type                   = "spot"
    kubelet_extra_args              = ""
    bootstrap_extra_args            = ""

    #self managed node group network configuration
    subnet_type = "public" # private or public
    subnet_ids  = []

    #security_group ID
    self_managed_custom_security_group_id = "" # Add custom sec group id if required from intended vpc or module creates new one.

  },

  #---------------------------------------------------------#
  # Bottlerocket Self Managed Worker Group - Worker Group - 3
  #---------------------------------------------------------#
  bottlerocket_mg_4 = {
    self_managed_nodegroup_name     = "bottlerocket-mg-4"
    os_ami_type                     = "bottlerocket"          # amazonlinux2eks  or bottlerocket or windows
    self_managed_node_ami_id        = "ami-044b114caf98ce8c5" # Modify this to fetch to use custom AMI ID.
    self_managed_node_userdata      = ""
    self_managed_node_volume_size   = "20"
    self_managed_node_instance_type = "m5.large"
    self_managed_node_desired_size  = "2"
    self_managed_node_max_size      = "5"
    self_managed_node_min_size      = "2"
    capacity_type                   = "" # Leave this empty if not for SPOT capacity.
    kubelet_extra_args              = ""
    bootstrap_extra_args            = ""

    #self managed node group network configuration
    subnet_type = "public" # private or public
    subnet_ids  = []

    #security_group ID
    self_managed_custom_security_group_id = "" # Add custom sec group id if required from intended vpc or module creates new one.

  },

}


#---------------------------------------------------------#
# EKS WORKER NODE GROUPS
#---------------------------------------------------------#

managed_node_groups = {
  //  #---------------------------------------------------------#
  //  # ON-DEMAND Worker Group - Worker Group - 1
  //  #---------------------------------------------------------#
  mg_4 = {
    # 1> Node Group configuration - Part1
    node_group_name        = "mg_4"
    create_launch_template = true              # false will use the default launch template
    custom_ami_type        = "amazonlinux2eks" # amazonlinux2eks or windows or bottlerocket
    public_ip              = false             # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
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
    instance_types = ["m4.large"]
    disk_size      = 50

    # 4> Node Group network configuration
    subnet_type = "private" # private or public
    subnet_ids  = []

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
  },
  #---------------------------------------------------------#
  # SPOT Worker Group - Worker Group - 2
  #---------------------------------------------------------#
  spot_m5 = {
    # 1> Node Group configuration - Part1
    node_group_name        = "spot_m5"
    create_launch_template = true              # false will use the default launch template
    custom_ami_type        = "amazonlinux2eks" # amazonlinux2eks  or bottlerocket
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
    subnet_type = "private" # private or public
    subnet_ids  = []

    //         k8s_taints = [{
    //           key = "dedicated"
    //           value = "gpuGroup"
    //           effect = "NO_SCHEDULE"
    //         }]
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
  },

  #---------------------------------------------------------#
  # BOTTLEROCKET - Worker Group - 3
  #---------------------------------------------------------#
  brkt_m5 = {
    node_group_name        = "brkt_m5"
    create_launch_template = true           # false will use the default launch template
    custom_ami_type        = "bottlerocket" # amazonlinux2eks  or bottlerocket
    public_ip              = false          # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
    pre_userdata           = ""
    desired_size           = 3
    max_size               = 3
    min_size               = 3
    max_unavailable        = 1

    ami_type       = "CUSTOM"
    capacity_type  = "ON_DEMAND" # ON_DEMAND or SPOT
    instance_types = ["m5.large"]
    disk_size      = 50
    custom_ami_id  = "ami-044b114caf98ce8c5" # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami-bottlerocket.html

    subnet_ids = ["subnet-xxx", "subnet-xxx", "subnet-xxx"]

    k8s_taints = {}
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
  }
}

#---------------------------------------------------------#
# Creates a Fargate profiles
#---------------------------------------------------------#
enable_fargate = false

fargate_profiles = {
  default = {
    fargate_profile_name = "default"
    fargate_profile_namespaces = [{
      namespace = "default"
      k8s_labels = {
        Environment = "preprod"
        Zone        = "dev"
        OS          = "Fargate"
        WorkerType  = "fargate"
        Namespace   = "default"
      }
    }]

    subnet_ids = []

    additional_tags = {
      ExtraTag    = "Fargate"
      Name        = "Fargate"
      subnet_type = "private"
    }
  },
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

    subnet_ids = []

    additional_tags = {
      ExtraTag = "Fargate"
      Name     = "Fargate"
    }
  },
}



# Enable logging only when you create a Fargate profile e.g., enable_fargate = true
fargate_fluent_bit_enable = false

#---------------------------------------------------------#
# SELF-MANAGED WINDOWS NODE GROUP (WORKER GROUP)
#---------------------------------------------------------#
#enable_self_managed_nodegroups = false
#enable_windows_support         = false
#self_managed_nodegroup_name    = "ng-windows"

#---------------------------------------------------------#
# ENABLE HELM MODULES
# Please note that you may need to download the docker images for each
#          helm module and push it to ECR if you create fully private EKS Clusters with no access to internet to fetch docker images.
#          README with instructions available in each HELM module under helm/
#---------------------------------------------------------#
# Enable this if worker Node groups has access to internet to download the docker images
# Or Make it false and set the private contianer image repo url in source/eks.tf; currently this defaults to ECR
public_docker_repo = true

#---------------------------------------------------------#
# ENABLE METRICS SERVER
#---------------------------------------------------------#
metrics_server_enable            = false
metric_server_image_tag          = "0.5.0-debian-10-r83"
metric_server_helm_chart_version = "5.9.2"
#---------------------------------------------------------#
# ENABLE CLUSTER AUTOSCALER
#---------------------------------------------------------#
cluster_autoscaler_enable       = true
cluster_autoscaler_image_tag    = "v1.20.0"
cluster_autoscaler_helm_version = "9.9.2"

#---------------------------------------------------------//
# ENABLE AWS LB INGRESS CONTROLLER
#---------------------------------------------------------//
lb_ingress_controller_enable = false
aws_lb_image_tag             = "v2.2.1"
aws_lb_helm_chart_version    = "1.2.3"

#---------------------------------------------------------//
# ENABLE PROMETHEUS
#---------------------------------------------------------//
# Creates the AMP workspace and all the relevent IAM Roles
aws_managed_prometheus_enable = false

# Deploys Pometheus server with remote write to AWS AMP Workspace
prometheus_enable             = false
prometheus_helm_chart_version = "14.4.0"
prometheus_image_tag          = "v2.26.0"
alert_manager_image_tag       = "v0.21.0"
configmap_reload_image_tag    = "v0.5.0"
node_exporter_image_tag       = "v1.1.2"
pushgateway_image_tag         = "v1.3.1"

#---------------------------------------------------------#
# ENABLE AWS_FLUENT-BIT
#---------------------------------------------------------#
aws_for_fluent_bit_enable             = false
ekslog_retention_in_days              = 7
aws_for_fluent_bit_image_tag          = "2.17.0"
aws_for_fluent_bit_helm_chart_version = "0.1.11"
