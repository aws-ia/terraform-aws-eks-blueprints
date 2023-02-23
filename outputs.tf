#-------------------------------
# EKS Cluster Module Outputs
#-------------------------------
output "eks_cluster_arn" {
  description = "Amazon EKS Cluster Name"
  value       = module.aws_eks.cluster_arn
}

output "eks_cluster_id" {
  description = "Amazon EKS Cluster Name"
  value       = module.aws_eks.cluster_id
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.aws_eks.cluster_certificate_authority_data
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.aws_eks.cluster_endpoint
}

output "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = try(split("//", module.aws_eks.cluster_oidc_issuer_url)[1], "EKS Cluster not enabled") # TODO - remove `split()` since `oidc_provider` coverss https:// removal
}

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.aws_eks.oidc_provider
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
  value       = module.aws_eks.oidc_provider_arn
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.context.aws_region_name} update-kubeconfig --name ${module.aws_eks.cluster_id}"
}

output "eks_cluster_status" {
  description = "Amazon EKS Cluster Status"
  value       = module.aws_eks.cluster_status
}

output "eks_cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.aws_eks.cluster_version
}

#-------------------------------
# Cluster Security Group
#-------------------------------
output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.aws_eks.cluster_primary_security_group_id
}

output "cluster_security_group_id" {
  description = "EKS Control Plane Security Group ID"
  value       = module.aws_eks.cluster_security_group_id
}

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = module.aws_eks.cluster_security_group_arn
}

#-------------------------------
# EKS Worker Security Group
#-------------------------------
output "worker_node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the worker node shared security group"
  value       = try(module.aws_eks.node_security_group_arn, "EKS Node groups not enabled")
}

output "worker_node_security_group_id" {
  description = "ID of the worker node shared security group"
  value       = try(module.aws_eks.node_security_group_id, "EKS Node groups not enabled")
}

#---------------------------------
# Self-managed Node Groups Outputs
#---------------------------------
output "self_managed_node_groups" {
  description = "Outputs from EKS Self-managed node groups "
  value       = var.create_eks && length(var.self_managed_node_groups) > 0 ? module.aws_eks_self_managed_node_groups[*] : []
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
  value       = local.self_managed_node_group_aws_auth_config_map[*]
}

output "windows_node_group_aws_auth_config_map" {
  description = "Windows node groups AWS auth map"
  value       = local.windows_node_group_aws_auth_config_map[*]
}

#--------------------------------
# EKS Managed Node Groups Outputs
#--------------------------------
output "managed_node_groups" {
  description = "Outputs from EKS Managed node groups "
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? module.aws_eks_managed_node_groups[*] : []
}

output "managed_node_groups_id" {
  description = "EKS Managed node groups id"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_id) }) : []
}

output "managed_node_groups_status" {
  description = "EKS Managed node groups status"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_status) }) : []
}

output "managed_node_group_arn" {
  description = "Managed node group arn"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_arn) }) : []
}

output "managed_node_group_iam_role_names" {
  description = "IAM role names of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_role_name) }) : []
}

output "managed_node_group_iam_role_arns" {
  description = "IAM role arn's of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_role_arn) }) : []
}

output "managed_node_group_iam_instance_profile_id" {
  description = "IAM instance profile id of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_instance_profile_id) }) : []
}

output "managed_node_group_iam_instance_profile_arns" {
  description = "IAM instance profile arn's of managed node groups"
  value       = var.create_eks && length(var.managed_node_groups) > 0 ? values({ for nodes in keys(var.managed_node_groups) : nodes => join(",", module.aws_eks_managed_node_groups[nodes].managed_nodegroup_iam_instance_profile_arn) }) : []
}

output "managed_node_group_aws_auth_config_map" {
  description = "Managed node groups AWS auth map"
  value       = local.managed_node_group_aws_auth_config_map[*]
}

#-------------------------------
# Fargate Profile Outputs
#-------------------------------
output "fargate_profiles" {
  description = "Outputs from EKS Fargate profiles groups "
  value       = module.aws_eks_fargate_profiles
}

output "fargate_profiles_iam_role_arns" {
  description = "IAM role arn's for Fargate Profiles"
  value       = var.create_eks && length(var.fargate_profiles) > 0 ? { for nodes in sort(keys(var.fargate_profiles)) : nodes => module.aws_eks_fargate_profiles[nodes].eks_fargate_profile_role_name } : null
}

output "fargate_profiles_aws_auth_config_map" {
  description = "Fargate profiles AWS auth map"
  value       = local.fargate_profiles_aws_auth_config_map
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
  description = "Output of the teams module. This contains the IAM roles arn of platform and application teams"
  value       = var.create_eks && (length(var.platform_teams) > 0 || length(var.application_teams) > 0) ? module.aws_eks_teams[*] : []
}
