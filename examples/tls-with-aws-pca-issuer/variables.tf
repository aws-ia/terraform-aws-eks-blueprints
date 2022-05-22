variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "pca001"
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

variable "certificate_name" {
  type        = string
  description = "name for the certificate"
  default     = "example"
}

variable "certificate_dns" {
  type        = string
  description = "CommonName used in the Certificate, usually DNS "
  default     = "example.com"
}
