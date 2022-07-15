output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "emrcontainers_virtual_cluster_id" {
  description = "EMR Containers Virtual cluster ID"
  value       = aws_emrcontainers_virtual_cluster.this.id
}

output "emr_on_eks_role_id" {
  description = "IAM execution role ID for EMR on EKS"
  value       = module.eks_blueprints.emr_on_eks_role_id
}

output "emr_on_eks_role_arn" {
  description = "IAM execution role arn for EMR on EKS"
  value       = module.eks_blueprints.emr_on_eks_role_arn
}

output "aws_fsx_lustre_file_system_arn" {
  description = "Amazon Resource Name of the file system"
  value       = aws_fsx_lustre_file_system.this.arn
}

output "aws_fsx_lustre_file_system_id" {
  description = "Identifier of the file system, e.g., fs-12345678"
  value       = aws_fsx_lustre_file_system.this.id
}

output "aws_fsx_lustre_file_system_dns_name" {
  description = "DNS name for the file system, e.g., fs-12345678.fsx.us-west-2.amazonaws.com"
  value       = aws_fsx_lustre_file_system.this.dns_name
}

output "aws_fsx_lustre_file_system_mount_name" {
  description = "The value to be used when mounting the filesystem"
  value       = aws_fsx_lustre_file_system.this.mount_name
}

output "aws_fsx_lustre_file_system_owner_id" {
  description = "AWS account identifier that created the file system"
  value       = aws_fsx_lustre_file_system.this.owner_id
}
