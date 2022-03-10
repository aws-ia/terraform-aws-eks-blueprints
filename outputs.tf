#-------------------------------
# EKS CLuster Module Outputs
#-------------------------------
output "eks_cluster_id" {
  description = "Kubernetes Cluster Name"
  value       = var.create_eks ? module.aws_eks.cluster_id : "EKS Cluster not enabled"
}

output "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = var.create_eks ? split("//", module.aws_eks.cluster_oidc_issuer_url)[1] : "EKS Cluster not enabled"
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = var.create_eks ? module.aws_eks.oidc_provider_arn : "EKS Cluster not enabled"
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = var.create_eks ? "aws eks --region ${local.context.aws_region_name} update-kubeconfig --name ${module.aws_eks.cluster_id}" : "EKS Cluster not enabled"
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

#-------------------------------
# Managed Node Groups Outputs
#-------------------------------
output "self_managed_node_groups" {
  description = "Outputs from EKS Self-managed node groups "
  value       = var.create_eks && length(var.self_managed_node_groups) > 0 ? module.aws_eks_self_managed_node_groups.* : []
}

output "self_managed_node_group_iam_role_arns" {
  description = "IAM role arn's of self managed node groups"
  value       = var.create_eks && length(var.self_managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.self_managed_node_groups)) : nodes => join(",", module.aws_eks_self_managed_node_groups[nodes].self_managed_nodegroup_iam_role_arns) }) : []
}

output "self_managed_node_group_autoscaling_groups" {
  description = "Autoscaling group names of self managed node groups"
  value       = var.create_eks && length(var.self_managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.self_managed_node_groups)) : nodes => join(",", module.aws_eks_self_managed_node_groups[nodes].self_managed_asg_names) }) : []
}

output "self_managed_node_group_iam_instance_profile_id" {
  description = "IAM instance profile id of managed node groups"
  value       = var.create_eks && length(var.self_managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.self_managed_node_groups)) : nodes => join(",", module.aws_eks_self_managed_node_groups[nodes].self_managed_nodegroup_iam_instance_profile_id) }) : []
}

output "self_managed_node_group_aws_auth_config_map" {
  description = "Self managed node groups AWS auth map"
  value       = local.self_managed_node_group_aws_auth_config_map.*
}

output "windows_node_group_aws_auth_config_map" {
  description = "Windows node groups AWS auth map"
  value       = local.windows_node_group_aws_auth_config_map.*
}
#-------------------------------
# Managed Node Groups Outputs
#-------------------------------
output "managed_node_groups" {
  description = "Outputs from EKS Managed node groups "
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? module.aws_eks_managed_node_groups.* : []
}

output "managed_node_group_iam_role_arns" {
  description = "IAM role arn's of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.managed_node_groups)) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_role_name) }) : []
}

output "managed_node_group_iam_instance_profile_id" {
  description = "IAM instance profile id of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.managed_node_groups)) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_instance_profile_id) }) : []
}

output "managed_node_group_iam_instance_profile_arns" {
  description = "IAM instance profile arn's of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in sort(keys(var.managed_node_groups)) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_instance_profile_arn) }) : []
}

output "managed_node_group_aws_auth_config_map" {
  description = "Managed node groups AWS auth map"
  value       = local.managed_node_group_aws_auth_config_map.*
}

#-------------------------------
# Fargate Profile Outputs
#-------------------------------
output "fargate_profiles" {
  description = "Outputs from EKS Fargate profiles groups "
  value       = var.create_eks && length(var.fargate_profiles) > 0 ? module.aws_eks_fargate_profiles.* : []
}

output "fargate_profiles_iam_role_arns" {
  description = "IAM role arn's for Fargate Profiles"
  value       = var.create_eks && length(var.fargate_profiles) > 0 ? { for nodes in sort(keys(var.fargate_profiles)) : nodes => module.aws_eks_fargate_profiles[nodes].eks_fargate_profile_role_name } : null
}

output "fargate_profiles_aws_auth_config_map" {
  description = "Fargate profiles AWS auth map"
  value       = local.fargate_profiles_aws_auth_config_map.*
}

#-------------------------------
# EMR on EKS Outputs
#-------------------------------
output "emr_on_eks_role_arn" {
  description = "IAM execution role ARN for EMR on EKS"
  value       = var.create_eks && var.enable_emr_on_eks ? values({ for nodes in sort(keys(var.emr_on_eks_teams)) : nodes => join(",", module.emr_on_eks[nodes].emr_on_eks_role_arn) }) : []
}

output "emr_on_eks_role_id" {
  description = "IAM execution role ID for EMR on EKS"
  value       = var.create_eks && var.enable_emr_on_eks ? values({ for nodes in sort(keys(var.emr_on_eks_teams)) : nodes => join(",", module.emr_on_eks[nodes].emr_on_eks_role_id) }) : []
}

#-------------------------------
# Teams(Soft Multi-tenancy) Outputs
#-------------------------------
output "teams" {
  description = "Outputs from EKS Fargate profiles groups "
  value       = var.create_eks && (length(var.platform_teams) > 0 || length(var.application_teams) > 0) ? module.aws_eks_teams.* : []
}

#-------------------------------
# Amazon Prometheus WorkSpace Outputs
#-------------------------------
output "amazon_prometheus_workspace_endpoint" {
  description = "Amazon Managed Prometheus Workspace Endpoint"
  value       = var.create_eks && var.enable_amazon_prometheus ? module.aws_managed_prometheus[0].amazon_prometheus_workspace_endpoint : null
}
