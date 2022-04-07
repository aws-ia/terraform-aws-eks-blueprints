output "role_arn" {
  value       = aws_iam_role.codepipeline_role.arn
  description = "The ARN of the IAM Role"
}