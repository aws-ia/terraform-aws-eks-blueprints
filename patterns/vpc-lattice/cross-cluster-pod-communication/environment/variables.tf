variable "organization" {
  type        = string
  description = "organization for the certificate"
  default     = "octank"
}

variable "custom_domain_name" {
  description = "Custom domain name for the private hosted zone"
  type        = string
  default     = "vpc-lattice-octank.io"
}
