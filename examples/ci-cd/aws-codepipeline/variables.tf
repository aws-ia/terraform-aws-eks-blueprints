variable "aws_profile" {
  description = "Profile to be used to connect to the target AWS account"
  type        = string
  default     = "default"
}

variable "account_id" {
  description = "Name of the account to be used"
  type        = string
  default     = "xxxxx"
}

variable "namespace" {
  description = "namespace, which could be your organization name, e.g. amazon"
  type        = string
  default     = "AWS"
}

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "create_new_repo" {
  description = "Whether to create a new repository. Values are true or false. Defaulted to true always."
  type        = bool
  default     = true
}

variable "source_repo_name" {
  description = "Source repo name of the CodeCommit repository"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
}

variable "ENVIRONMENT" {
  description = "Environment in which the script is run. Eg: dev, prod, etc"
  type        = string
}


variable "build_spec_file_path_validate" {
  description = "Relative path to the Validate and Plan build spec file"
  type        = string
  default     = "./templates/buildspec_validate.yml"
}

variable "build_spec_file_path_plan" {
  description = "Relative path to the Apply and Destroy build spec file"
  type        = string
  default     = "./templates/buildspec_plan.yml"
}

variable "build_spec_file_path_apply" {
  description = "Relative path to the Apply and Destroy build spec file"
  type        = string
  default     = "./templates/buildspec_apply.yml"
}

variable "build_spec_file_path_destroy" {
  description = "Relative path to the Apply and Destroy build spec file"
  type        = string
  default     = "./templates/buildspec_destroy.yml"
}
