variable "create_new_repo" {
  type        = bool
  description = "Flag for deciding if a new repository needs to be created"
  default     = false
}

variable "source_repository_name" {
  type        = string
  description = "Name of the Source CodeCommit repository"
}

variable "source_repository_tags" {
  type        = map(any)
  description = "Tags to be attached to the source CodeCommit repository"
}