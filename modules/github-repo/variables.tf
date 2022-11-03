variable "name" {
  description = "The name of the GitHub repository that will be created."
  type = string
}

variable "description" {
  description = "The description of the GitHub repository that will be created."
  type = string
  default = ""
}

variable "visibility" {
  description = "The visibility of the GitHub repository that will be created."
  type = string
  default = "public"
}

variable "template_owner" {
  description = "GitHub template repository name. (Default: provider_owner)"
  type = string
  default = ""
}

variable "template_repo_name" {
  description = "GitHub template repository name. (Will not use a template, if not set)"
  type = string
  default = ""
}

variable "provider_owner" {
  description = "Github provider account/organisation."
  type        = string
}

variable "provider_token" {
  description = "Github provider token."
  type        = string
  sensitive   = true
}