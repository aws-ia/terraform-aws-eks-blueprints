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
