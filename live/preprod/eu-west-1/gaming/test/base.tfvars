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
# Use this only when you create Public subnets
enable_nat_gateway = true
#If single_nat_gateway = true, then all private subnets will route their Internet traffic through this single NAT gateway. The NAT gateway will be placed in the first public subnet in your public_subnets block
single_nat_gateway = true
create_igw         = true

vpc_cidr_block       = "10.1.0.0/18"
private_subnets_cidr = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
public_subnets_cidr  = ["10.1.12.0/22", "10.1.16.0/22", "10.1.20.0/22"]


#---------------------------------------------------------#
# OPTION 2
#---------------------------------------------------------#
//create_vpc = false
//vpc_id = "xxxxxx"
//private_subnet_ids = ['xxxxxx','xxxxxx','xxxxxx']

#---------------------------------------------------------#
# EKS CONTROL PLANE VARIABLES
#---------------------------------------------------------#
kubernetes_version      = "1.20"
endpoint_private_access = false
endpoint_public_access  = true
enable_irsa             = true

enabled_cluster_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_period = 7


#---------------------------------------------------------#
# WORKER NODE GROUPS SECTION
# Define the following parameters to create EKS Node groups. If you need to two Node groups then you may need to duplicate the with different instance type
# NOTE: Also ensure Node groups config that you defined below needs to exist in this file <aws-eks-accelerator-for-terraform/source/eks.tf>.
#         Comment out the node groups in <aws-eks-accelerator-for-terraform/source/eks.tf> file if you are not defining below.
#         This is a limitation at this moment that the change needs ot be done in two places. This will be improved later
#---------------------------------------------------------#
#---------------------------------------------------------#
# MANAGED WORKER NODE INPUT VARIABLES FOR ON DEMAND INSTANCES - Worker Group1
#---------------------------------------------------------#
on_demand_node_group_name = "mg-m5-on-demand"
on_demand_ami_type        = "AL2_x86_64"
on_demand_disk_size       = 50
on_demand_instance_type   = ["c5.large"]
on_demand_desired_size    = 3
on_demand_max_size        = 3
on_demand_min_size        = 3

#---------------------------------------------------------#
# BOTTLEROCKET - Worker Group3
#---------------------------------------------------------#
# Amazon EKS optimized Bottlerocket AMI ID for a region and Kubernetes version.
bottlerocket_node_group_name = "mg-m5-bottlerocket"
bottlerocket_ami             = "ami-0326716ad575410ab"
bottlerocket_disk_size       = 50
bottlerocket_instance_type   = ["m5.large"]
bottlerocket_desired_size    = 3
bottlerocket_max_size        = 3
bottlerocket_min_size        = 3
#---------------------------------------------------------#
# MANAGED WORKER NODE INPUT VARIABLES FOR SPOT INSTANCES - Worker Group2
#---------------------------------------------------------#
spot_node_group_name = "mg-m5-spot"
spot_instance_type   = ["m5.large", "m5a.large"]
spot_ami_type        = "AL2_x86_64"
spot_desired_size    = 3
spot_max_size        = 6
spot_min_size        = 3

#---------------------------------------------------------#
# Creates a Fargate profile for default namespace
#---------------------------------------------------------#
fargate_profile_namespace = "default"

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
metrics_server_enable = true

#---------------------------------------------------------#
# ENABLE CLUSTER AUTOSCALER
#---------------------------------------------------------#
cluster_autoscaler_enable = true


#---------------------------------------------------------//
# ENABLE ALB INGRESS CONTROLLER
#---------------------------------------------------------//
#lb_ingress_controller_enable = true

#---------------------------------------------------------#
# ENABLE AWS_FLUENT-BIT
#---------------------------------------------------------#
#aws_for_fluent_bit_enable = true
#fargate_fluent_bit_enable = true

#ekslog_retention_in_days = 1

#---------------------------------------------------------//
# ENABLE AGONES GAMING CONTROLLER
#   A library for hosting, running and scaling dedicated game servers on Kubernetes
#   This chart installs the Agones application and defines deployment on a  cluster
#   NOTE: Edit Rules to add a new Custom UDP Rule with a 7000-8000 port range and an appropriate Source CIDR range (0.0.0.0/0 allows all traffic) (sec group e.g., gaming-preprod-test-eks-eks_worker_sg)
#         By default Agones prefers to be scheduled on nodes labeled with agones.dev/agones-system=true and tolerates the node taint agones.dev/agones-system=true:NoExecute.
#         If no dedicated nodes are available, Agones will run on regular nodes.
#---------------------------------------------------------//
agones_enable = true
expose_udp    = true