#-------------------------------
# EKS Cluster Labels
#-------------------------------
variable "org" {
  type        = string
  description = "tenant, which could be your organization name, e.g. aws'"
  default     = ""
}

variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "aws"
}

variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "terraform_version" {
  type        = string
  default     = "Terraform"
  description = "Terraform version"
}

#-------------------------------
# VPC Config for EKS Cluster
#-------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC Id"
}

variable "private_subnet_ids" {
  description = "List of private subnets Ids for the worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnets Ids for the worker nodes"
  type        = list(string)
  default     = []
}

#-------------------------------
# EKS module variables (terraform-aws-modules/eks/aws)
#-------------------------------
variable "create_eks" {
  type        = bool
  default     = true
  description = "Create EKS cluster"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.21"
  description = "Desired kubernetes version. If you do not specify a value, the latest available version is used"
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "EKS Cluster Name"
}

variable "cluster_kms_key_arn" {
  type        = string
  default     = null
  description = "A valid EKS Cluster KMS Key ARN to encrypt Kubernetes secrets"
}

variable "cluster_kms_key_deletion_window_in_days" {
  type        = number
  default     = 30
  description = "The waiting period, specified in number of days (7 - 30). After the waiting period ends, AWS KMS deletes the KMS key"
}

variable "cluster_endpoint_private_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the EKS private API server endpoint is enabled. Default to EKS resource and it is false"
}

variable "cluster_create_endpoint_private_access_sg_rule" {
  type        = bool
  default     = false
  description = "Whether to create security group rules for the access to the Amazon EKS private API server endpoint"
}

variable "cluster_endpoint_private_access_cidrs" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks which can access the Amazon EKS private API server endpoint"
}

variable "cluster_endpoint_private_access_sg" {
  type        = list(string)
  default     = []
  description = "List of security group IDs which can access the Amazon EKS private API server endpoint"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the EKS public API server endpoint is enabled. Default to EKS resource and it is true"
}

variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
}

variable "cluster_log_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
  default     = 90
}

variable "enable_irsa" {
  type        = bool
  default     = true
  description = "Enable IAM Roles for Service Accounts"
}

variable "cluster_enabled_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "A list of the desired control plane logging to enable"
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain cluster logs"
}

variable "worker_create_security_group" {
  description = "Whether to create a security group for the workers or attach the workers to `worker_security_group_id`."
  type        = bool
  default     = true
}

#-------------------------------
# Node Groups
#-------------------------------
variable "managed_node_groups" {
  description = "Managed node groups configuration"
  type        = any
  default     = {}
}

variable "self_managed_node_groups" {
  description = "Self-managed node groups configuration"
  type        = any
  default     = {}
}

variable "enable_windows_support" {
  description = "Enable Windows support"
  type        = bool
  default     = false
}

#-------------------------------
# Worker Additional Variables
#-------------------------------
variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = list(string)
  default     = []
}

#-------------------------------
# Fargate
#-------------------------------
variable "fargate_profiles" {
  description = "Fargate profile configuration"
  type        = any
  default     = {}
}

#-------------------------------
# aws-auth Config Map
#-------------------------------
variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_additional_labels" {
  description = "Additional kubernetes labels applied on aws-auth ConfigMap"
  default     = {}
  type        = map(string)
}

#-------------------------------
# Amazon Managed Prometheus
#-------------------------------
variable "enable_amazon_prometheus" {
  type        = bool
  default     = false
  description = "Enable AWS Managed Prometheus service"
}

variable "amazon_prometheus_workspace_alias" {
  type        = string
  default     = null
  description = "AWS Managed Prometheus WorkSpace Name"
}

#-------------------------------
# Amazon EMR on EKS
#-------------------------------
variable "enable_emr_on_eks" {
  type        = bool
  default     = false
  description = "Enable EMR on EKS"
}

variable "emr_on_eks_teams" {
  description = "EMR on EKS Teams config"
  type        = any
  default     = {}
}

#-------------------------------
# TEAMS (Soft Multi-tenancy)
#-------------------------------
variable "application_teams" {
  description = "Map of maps of Application Teams to create"
  type        = any
  default     = {}
}

variable "platform_teams" {
  description = "Map of maps of platform teams to create"
  type        = any
  default     = {}
}
