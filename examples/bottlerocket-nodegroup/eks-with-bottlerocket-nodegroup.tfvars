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
# EKS WORKER NODE GROUPS
#---------------------------------------------------------#
enable_managed_nodegroups = true
managed_node_groups = {
  #---------------------------------------------------------#
  # BOTTLEROCKET - Worker Group - 3
  #---------------------------------------------------------#
  brkt_t3 = {
    node_group_name        = "brkt_t3"
    create_launch_template = true           # false will use the default launch template
    custom_ami_type        = "bottlerocket" # amazonlinux2eks or windows or bottlerocket
    public_ip              = false          # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
    pre_userdata           = ""
    desired_size           = 3
    max_size               = 3
    min_size               = 3
    max_unavailable        = 1

    ami_type       = "CUSTOM"
    capacity_type  = "ON_DEMAND" # ON_DEMAND or SPOT
    instance_types = ["t3a.large"]
    disk_size      = 50
    custom_ami_id  = "ami-044b114caf98ce8c5" # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami-bottlerocket.html

    subnet_type = "private" # private or public
    subnet_ids  = []        # Optional - It will pickup the default private/public subnets
    # enable_ssh = true                           # Optional - Feature not implemented - Recommends to leverage Systems Manager

    k8s_taints = {} # Optional
    k8s_labels = {
      Environment = "preprod"
      Zone        = "test"
      OS          = "bottlerocket"
      WorkerType  = "ON_DEMAND_BOTTLEROCKET"
    }
    additional_tags = {
      ExtraTag    = "bottlerocket"
      Name        = "bottlerocket"
      subnet_type = "private" # This is mandatory tage for placing the nodes into PUBLIC or PRIVATE subnets
    }

    #security_group ID
    create_worker_security_group = true
  }
}

#---------------------------------------------------------#
# SELF-MANAGED WINDOWS NODE GROUP (WORKER GROUP)
#---------------------------------------------------------#
enable_self_managed_nodegroups = true
self_managed_node_groups = {
  #---------------------------------------------------------#
  # Bottlerocket Self Managed Worker Group - Worker Group - 3
  #---------------------------------------------------------#
  bottlerocket_mg_4 = {
    self_managed_nodegroup_name     = "bottlerocket-mg-4"
    custom_ami_type                 = "bottlerocket"          # amazonlinux2eks  or bottlerocket or windows
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
    subnet_type = "private" # private or public
    subnet_ids  = []

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

public_docker_repo = true

#---------------------------------------------------------#
# ENABLE METRICS SERVER
#---------------------------------------------------------#
metrics_server_enable            = true
metric_server_image_tag          = "v0.4.2"
metric_server_helm_chart_version = "2.12.1"
#---------------------------------------------------------#
# ENABLE CLUSTER AUTOSCALER
#---------------------------------------------------------#
cluster_autoscaler_enable       = true
cluster_autoscaler_image_tag    = "v1.20.0"
cluster_autoscaler_helm_version = "9.9.2"

