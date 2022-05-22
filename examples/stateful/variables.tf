variable "tenant" {
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  type        = string
  default     = "aws001"
}

variable "environment" {
  description = "Environment area, e.g. prod or preprod "
  type        = string
  default     = "preprod"
}

variable "zone" {
  description = "Zone, e.g. dev or qa or load or ops etc..."
  type        = string
  default     = "dev"
}
