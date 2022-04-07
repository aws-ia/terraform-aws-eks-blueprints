resource "aws_codecommit_repository" "source_repository" {
  count           = var.create_new_repo ? 1 : 0
  repository_name = var.source_repository_name
  description     = "Code Repository for hosting the terraform code and pipeline configuration files"
  tags            = var.tags
}