variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "sm001"
}

variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default     = "dev"
}

variable "application" {
  type        = string
  description = "Name of the application"
  default     = "nginx"
}
