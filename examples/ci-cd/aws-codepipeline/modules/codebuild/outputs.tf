# Outputs

output "id" {
  value       = aws_codebuild_project.terraform_codebuild_project[*].id
  description = "List of IDs of the CodeBuild projects"
}

output "name" {
  value       = aws_codebuild_project.terraform_codebuild_project[*].name
  description = "List of Names of the CodeBuild projects"
}

output "arn" {
  value       = aws_codebuild_project.terraform_codebuild_project[*].arn
  description = "List of ARNs of the CodeBuild projects"
}

