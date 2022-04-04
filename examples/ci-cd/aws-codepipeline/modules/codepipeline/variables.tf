variable "account_id" {
  description = "Name of the account to be used"
  default     = ""
}

variable "namespace" {
  description = "namespace, which could be your organiation name, e.g. amazon"
  default     = "AWS"
}

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "source_repo_name" {
  description = "Source repo name of the CodeCommit repository"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name to be used for storing the artifacts"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the previously created codepipeline role"
  type        = string
  default     = ""
}

variable "codebuild_validate_project_arn" {
  description = "CodeBuild arn of the Validate project"
  type        = string
}

variable "codebuild_plan_project_arn" {
  description = "CodeBuild arn of the Plan project"
  type        = string
}

variable "codebuild_apply_project_arn" {
  description = "CodeBuild arn of the Apply project"
  type        = string
}

variable "codebuild_destroy_project_arn" {
  description = "CodeBuild arn of the Destroy project"
  type        = string
}

variable "post_validation_status" {
  description = "Whether to update the validation status in Pull Request. Default is always set to true."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}
