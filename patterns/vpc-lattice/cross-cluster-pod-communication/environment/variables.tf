variable "organization" {
  type        = string
  description = "organization for the certificate"
  default     = "octank"
}

variable "certificate_name" {
  type        = string
  description = "name for the certificate"
  default     = "vpc-lattice-octank"
}

variable "custom_domain_name" {
  description = "Custom domain name for the private hosted zone"
  type        = string
  default     = "vpc-lattice-octank.io"
}