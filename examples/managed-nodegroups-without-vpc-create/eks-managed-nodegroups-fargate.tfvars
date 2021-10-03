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
zone              = "test"    # Environment with in one sub_tenant or business unit
terraform_version = "Terraform v1.0.1"
#---------------------------------------------------------#
# VPC and PRIVATE SUBNET DETAILS for EKS Cluster
#---------------------------------------------------------#
#This provides two options Option1 and Option2. You should choose either of one to provide VPC details to the EKS cluster
#Option1: Creates a new VPC, private Subnets and VPC Endpoints by taking the inputs of vpc_cidr_block and private_subnets_cidr. VPC Endpoints are S3, SSM , EC2, ECR API, ECR DKR, KMS, CloudWatch Logs, STS, Elastic Load Balancing, Autoscaling
#Option2: Provide an existing vpc_id and private_subnet_ids

#---------------------------------------------------------#
# OPTION 2
#---------------------------------------------------------#
create_vpc           = false
create_vpc_endpoints = false
vpc_id               = "vpc-0a172d7ab14ae0dbd"
private_subnet_ids   = ["subnet-0145a0dba9edb8d67", "subnet-044af15285bba8e1f", "subnet-03ee35df9c9a5a742"]
public_subnet_ids    = ["subnet-0a9337324c52d5dc0", "subnet-06def9e7375d363e7", "subnet-0e93905699dfe543c"]

//#---------------------------------------------------------#
# EKS CONTROL PLANE VARIABLES
# API server endpoint access options
#   Endpoint public access: true    - Your cluster API server is accessible from the internet. You can, optionally, limit the CIDR blocks that can access the public endpoint.
#   Endpoint private access: true   - Kubernetes API requests within your cluster's VPC (such as node to control plane communication) use the private VPC endpoint.
#---------------------------------------------------------#
create_eks              = true
kubernetes_version      = "1.21"
endpoint_private_access = true
endpoint_public_access  = true

# Enable IAM Roles for Service Accounts (IRSA) on the EKS cluster
enable_irsa = true

enabled_cluster_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_period = 7

enable_vpc_cni_addon  = true
vpc_cni_addon_version = "v1.9.1-eksbuild.1"

enable_coredns_addon  = true
coredns_addon_version = "v1.8.4-eksbuild.1"

enable_kube_proxy_addon  = true
kube_proxy_addon_version = "v1.21.2-eksbuild.2"


#---------------------------------------------------------#
# EKS WORKER NODE GROUPS
# Define Node groups as map of maps object as shown below. Each node group creates the following
#    1. New node group (Linux/Bottlerocket)
#    2. IAM role and policies for Node group
#    3. Security Group for Node group (Optional)
#    4. Launch Templates for Node group   (Optional)
#---------------------------------------------------------#
enable_managed_nodegroups = true
managed_node_groups = {
  #---------------------------------------------------------#
  # ON-DEMAND Worker Group - Worker Group - 1
  #---------------------------------------------------------#
  mg_4 = {
    # 1> Node Group configuration - Part1
    node_group_name        = "managed-ondemand"
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
    instance_types = ["m4.large"] # List of instances used only for SPOT type
    disk_size      = 50

    # 4> Node Group network configuration
    subnet_type = "private" # private or public
    subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

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
    custom_ami_type        = "bottlerocket" # amazonlinux2eks  or bottlerocket
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
    subnet_type = "private" # private or public
    subnet_ids  = []        # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']

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
    #security_group ID
    create_worker_security_group = true
  }

    */
} # END OF MANAGED NODE GROUPS

#---------------------------------------------------------#
# FARGATE PROFILES
#---------------------------------------------------------#
enable_fargate = true

# Enable logging only when you create a Fargate profile e.g., enable_fargate = true
fargate_fluent_bit_enable = false

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

#---------------------------------------------------------#
# ENABLE HELM MODULES
#---------------------------------------------------------#
# Please note that you may need to download the docker images for each
#    helm module and push it to ECR if you create fully private EKS Clusters with no access to internet to fetch docker images.
#    README with instructions available in each HELM module under helm/
#---------------------------------------------------------#
# Enable `public_docker_repo = true` if worker Node groups has access to internet to download the docker images
public_docker_repo = true

# If public_docker_repo = false then provide the private_container_repo_url or it will use ECR repo url
# private_container_repo_url = ""
#---------------------------------------------------------#
# ENABLE METRICS SERVER
#---------------------------------------------------------#
metrics_server_enable            = true
metric_server_image_repo_name    = "bitnami/metrics-server"
metric_server_image_tag          = "0.5.0-debian-10-r83"
metric_server_helm_repo_url      = "https://charts.bitnami.com/bitnami"
metric_server_helm_chart_name    = "metrics-server"
metric_server_helm_chart_version = "5.10.1"
#---------------------------------------------------------#
# ENABLE CLUSTER AUTOSCALER
#---------------------------------------------------------#
cluster_autoscaler_enable          = true
cluster_autoscaler_image_tag       = "v1.21.0"
cluster_autoscaler_helm_repo_url   = "https://kubernetes.github.io/autoscaler"
cluster_autoscaler_image_repo_name = "k8s.gcr.io/autoscaling/cluster-autoscaler"
cluster_autoscaler_helm_chart_name = "cluster-autoscaler"
cluster_autoscaler_helm_version    = "9.10.7"
