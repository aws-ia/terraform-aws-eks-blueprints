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

output "cluster_oidc_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = var.create_eks ? split("//", module.aws_eks.cluster_oidc_issuer_url)[1] : "EKS Cluster not enabled"
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = var.create_eks ? module.aws_eks.oidc_provider_arn : "EKS Cluster not enabled"
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = var.create_eks ? module.aws_eks.cluster_id : "EKS Cluster not enabled"
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = var.create_eks ? "aws eks --region ${data.aws_region.current.id} update-kubeconfig --name ${module.aws_eks.cluster_id}" : "EKS Cluster not enabled"
}

output "cluster_security_group_id" {
  description = "EKS Control Plane Security Group ID"
  value       = module.aws_eks.cluster_security_group_id
}

output "cluster_primary_security_group_id" {
  description = "EKS Cluster Security group ID"
  value       = module.aws_eks.cluster_primary_security_group_id
}

output "worker_security_group_id" {
  description = "EKS Worker Security group ID created by EKS module"
  value       = module.aws_eks.worker_security_group_id
}

output "amp_work_id" {
  description = "AWS Managed Prometheus workspace id"
  value       = var.aws_managed_prometheus_enable ? module.aws_managed_prometheus[0].amp_workspace_id : "AMP not enabled"
}

output "amp_work_arn" {
  description = "AWS Managed Prometheus workspace ARN"
  value       = var.aws_managed_prometheus_enable ? module.aws_managed_prometheus[0].service_account_amp_ingest_role_arn : "AMP not enabled"
}

output "self_managed_node_group_iam_role_arns" {
  description = "IAM role arn's of self managed node groups"
  value       = var.create_eks && length(var.self_managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.self_managed_node_groups)) : nodes => join(",", module.aws_eks_self_managed_node_groups[nodes].self_managed_node_group_iam_role_arns) }) : []
}

output "managed_node_group_iam_role_arns" {
  description = "IAM role arn's of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.managed_node_groups)) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_role_name) }) : []
}

output "fargate_profiles_iam_role_arns" {
  description = "IAM role arn's for Fargate Profiles"
  value       = var.create_eks && length(var.fargate_profiles) > 0 ? { for nodes in sort(keys(var.fargate_profiles)) : nodes => module.aws_eks_fargate_profiles[nodes].eks_fargate_profile_role_name } : null
}

output "managed_node_groups" {
  description = "Outputs from EKS Managed node groups "
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? module.aws_eks_managed_node_groups.* : []
}

output "self_managed_node_groups" {
  description = "Outputs from EKS Self-managed node groups "
  value       = var.create_eks && length(var.self_managed_node_groups) > 0 ? module.aws_eks_self_managed_node_groups.* : []
}

output "fargate_profiles" {
  description = "Outputs from EKS Fargate profiles groups "
  value       = var.create_eks && length(var.fargate_profiles) > 0 ? module.aws_eks_fargate_profiles.* : []
}

output "self_managed_node_group_aws_auth_config_map" {
  description = "Self managed node groups AWS auth map"
  value       = local.self_managed_node_group_aws_auth_config_map.*
}

output "windows_node_group_aws_auth_config_map" {
  description = "Windows node groups AWS auth map"
  value       = local.windows_node_group_aws_auth_config_map.*
}

output "managed_node_group_aws_auth_config_map" {
  description = "Managed node groups AWS auth map"
  value       = local.managed_node_group_aws_auth_config_map.*
}

output "fargate_profiles_aws_auth_config_map" {
  description = "Fargate profiles AWS auth map"
  value       = local.fargate_profiles_aws_auth_config_map.*
}

output "emr_on_eks_role_arn" {
  description = "IAM execution role ARN for EMR on EKS"
  value       = var.create_eks && var.enable_emr_on_eks ? values({ for nodes in sort(keys(var.emr_on_eks_teams)) : nodes => join(",", module.emr_on_eks[nodes].emr_on_eks_role_arn) }) : []
}

output "emr_on_eks_role_id" {
  description = "IAM execution role ID for EMR on EKS"
  value       = var.create_eks && var.enable_emr_on_eks ? values({ for nodes in sort(keys(var.emr_on_eks_teams)) : nodes => join(",", module.emr_on_eks[nodes].emr_on_eks_role_id) }) : []
}

output "teams" {
  description = "Outputs from EKS Fargate profiles groups "
  value       = var.create_eks && (length(var.platform_teams) > 0 || length(var.application_teams) > 0) ? module.aws_eks_teams.* : []
}
