variable "organization" {
  type        = string
  description = "organization for the certificate"
  default     = "example"
}

variable "custom_domain_name" {
  description = "Custom domain name for the private hosted zone"
  type        = string
  default     = "example.com"
}
