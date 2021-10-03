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
tenant            = "gaming"  # AWS account name or unique id for tenant
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
# OPTION 1
#---------------------------------------------------------#
create_vpc             = true
enable_private_subnets = true
enable_public_subnets  = true

# Enable or Disable NAT Gateqay and Internet Gateway for Public Subnets
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
//create_vpc = false
//vpc_id = "xxxxxx"
//private_subnet_ids = ['xxxxxx','xxxxxx','xxxxxx']

#---------------------------------------------------------#
# EKS CONTROL PLANE VARIABLES
# API server endpoint access options
#   Endpoint public access: true    - Your cluster API server is accessible from the internet. You can, optionally, limit the CIDR blocks that can access the public endpoint.
#   Endpoint private access: true   - Kubernetes API requests within your cluster's VPC (such as node to control plane communication) use the private VPC endpoint.
#---------------------------------------------------------#
create_eks              = false
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
#---------------------------------------------------------#
enable_managed_nodegroups = true
managed_node_groups = {
  mg_m5x = {
    # 1> Node Group configuration - Part1
    node_group_name        = "mg_m5x"
    create_launch_template = true              # false will use the default launch template
    custom_ami_type        = "amazonlinux2eks" # amazonlinux2eks or windows or bottlerocket
    public_ip              = true              # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
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
    instance_types = ["m5.xlarge"]
    disk_size      = 50

    # 4> Node Group network configuration
    subnet_type = "public" # private or public
    subnet_ids  = []       # Optional - It will use the default private/public subnets
    # enable_ssh = true     # Optional - Feature not implemented - Recommends to leverage Systems Manager

    k8s_labels = {
      Environment = "preprod"
      Zone        = "test"
      WorkerType  = "ON_DEMAND"
    }
    additional_tags = {
      ExtraTag    = "m5x-on-demand"
      Name        = "m5x-on-demand"
      subnet_type = "private"
    }

    #security_group ID
    create_worker_security_group = true

  },
}

#---------------------------------------------------------#
# ENABLE HELM MODULES
# Please note that you may need to download the docker images for each
#          helm module and push it to ECR if you create fully private EKS Clusters with no access to internet to fetch docker images.
#          README with instructions available in each HELM module under helm/
#---------------------------------------------------------#
# Enable this if worker Node groups has access to internet to download the docker images
# Or Make it false and set the private contianer image repo url in source/aws-eks.tf; currently this defaults to ECR
public_docker_repo = true

#---------------------------------------------------------//
# ENABLE AGONES GAMING CONTROLLER
#   A library for hosting, running and scaling dedicated game servers on Kubernetes
#   This chart installs the Agones application and defines deployment on a  cluster
#   NOTE: Edit Rules to add a new Custom UDP Rule with a 7000-8000 port range and an appropriate Source CIDR range (0.0.0.0/0 allows all traffic) (sec group e.g., gaming-preprod-test-eks-eks_worker_sg)
#         By default Agones prefers to be scheduled on nodes labeled with agones.dev/agones-system=true and tolerates the node taint agones.dev/agones-system=true:NoExecute.
#         If no dedicated nodes are available, Agones will run on regular nodes.
#---------------------------------------------------------//
agones_enable              = false
expose_udp                 = true
agones_helm_chart_name     = "agones"
agones_helm_chart_url      = "https://agones.dev/chart/stable"
agones_image_tag           = "1.15.0"
agones_image_repo          = "gcr.io/agones-images"
agones_game_server_minport = 7000
agones_game_server_maxport = 8000
#agones_helm_chart_version = ""