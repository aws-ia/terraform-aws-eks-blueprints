# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# defaults to directory name ${basename(path.cwd)}
variable "name" {
  description = "EKS Cluster Name and the VPC name"
  type        = string
  default     = ""
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.30"
}

variable "capacity_type" {
  type        = string
  description = "Capacity SPOT or ON_DEMAND"
  default     = "SPOT"
}

# defaults to data.aws_caller_identity.current.account_id
variable "ecr_account_id" {
  type        = string
  description = "ECR repository AWS Account ID"
  default     = ""
}

# defaults to local.region -> var.region
variable "ecr_region" {
  type        = string
  description = "ECR repository AWS Region"
  default     = ""
}

