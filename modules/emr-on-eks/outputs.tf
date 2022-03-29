output "emr_on_eks_role_arn" {
  description = "IAM execution role ARN for EMR on EKS"
  value       = aws_iam_role.emr_on_eks_execution[*].arn
}

output "emr_on_eks_role_id" {
  description = "IAM execution role ID for EMR on EKS"
  value       = aws_iam_role.emr_on_eks_execution[*].id
}
