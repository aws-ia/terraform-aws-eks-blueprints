# Outputs - Dynamic values to be output based on the value of create_new_repo

output "clone_url_http" {
  value = var.create_new_repo ? aws_codecommit_repository.source_repository[0].clone_url_http : data.aws_codecommit_repository.existing_repository[0].clone_url_http
}

output "repository_name" {
  value = var.create_new_repo ? aws_codecommit_repository.source_repository[0].repository_name : var.source_repository_name
}

output "arn" {
  value = var.create_new_repo ? aws_codecommit_repository.source_repository[0].arn : data.aws_codecommit_repository.existing_repository[0].arn
}
