variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "build_spec_file_path" {
  description = "Relative path to the build spec file"
  type        = string
  default     = "../../templates/buildspec_validate.yml"
}

variable "code_build_name" {
  description = "Unique name to be included for the CodeBuild name"
  type        = string
  default     = "validateApplyTerraform"
}

variable "create_role_and_policy" {
  description = "Whether to create a new IAM role and policy for code commit. "
  type        = bool
  default     = true
}

variable "role_arn" {
  description = "Codepipeline IAM role arn. "
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket used to store the configurations"
  type        = string
}

variable "tags" {
  description = "This is the tags which needs to be applied to the pipeline"
  type        = map(any)
}
