# To be used only in case of an Existing Repository
data "aws_codecommit_repository" "existing_repository" {
  count           = var.create_new_repo ? 0 : 1
  repository_name = var.source_repository_name
}
