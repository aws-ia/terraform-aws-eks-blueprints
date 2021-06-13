#---------------------------------------------------------#
# EKS CLUSTER CORE VARIABLES
#---------------------------------------------------------#
#Following fields used in tagging resources and building the name of the cluster
#e.g., eks cluster name will be {tenant}-{environment}-{zone}-{resource}
#---------------------------------------------------------#
org               = "aws"       # Organization Name. Used to tag resources
tenant            = "aws001"    # AWS account name or unique id for tenant
environment       = "preprod"   # Environment area eg., preprod or prod
zone              = "dev"       # Environment with in one sub_tenant or business unit
region            = "eu-west-1" # EKS Cluster region
terraform_version = "Terraform v1.0.0"
#---------------------------------------------------------#
# VPC and PRIVATE SUBNET DETAILS for EKS Cluster
#---------------------------------------------------------#
#This provides two options Option1 and Option2. You should choose either of one to provide VPC details to the EKS cluster
#Option1: Creates a new VPC, private Subnets and VPC Endpoints by taking the inputs of vpc_cidr_block and private_subnets_cidr. VPC Endpoints are S3, SSM , EC2, ECR API, ECR DKR, KMS, CloudWatch Logs, STS, Elastic Load Balancing, Autoscaling
#Option2: Provide an existing vpc_id and private_subnet_ids

#---------------------------------------------------------#
# OPTION 1
#---------------------------------------------------------#
create_vpc            = true
vpc_cidr_block        = "10.1.0.0/18"
private_subnets_cidr  = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
enable_public_subnets = false
//public_subnets_cidr = []

#---------------------------------------------------------#
# OPTION 2
#---------------------------------------------------------#
//create_vpc = false
//vpc_id = "xxxxxx"
//private_subnet_ids = ['xxxxxx','xxxxxx','xxxxxx']

#---------------------------------------------------------#
# EKS CONTROL PLANE VARIABLES
#---------------------------------------------------------#
kubernetes_version      = "1.19"
endpoint_private_access = true
endpoint_public_access  = true
enable_irsa             = true

enabled_cluster_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_period = 7

#---------------------------------------------------------#
# MANAGED WORKER NODE INPUT VARIABLES FOR ON DEMAND INSTANCES - Worker Group1
#---------------------------------------------------------#
on_demand_node_group_name = "mg-m5-on-demand"
on_demand_ami_type        = "AL2_x86_64"
on_demand_disk_size       = 50
on_demand_instance_type   = ["m5.xlarge"]
on_demand_desired_size    = 3
on_demand_max_size        = 3
on_demand_min_size        = 3

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




