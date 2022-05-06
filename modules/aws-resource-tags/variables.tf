variable "org" {
  type        = string
  description = "tenant, which could be your organization name, e.g. aws'"
  default     = ""
}

variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
}

variable "environment" {
  type        = string
  description = "zone, e.g. 'prod', 'preprod' "
}

variable "zone" {
  type        = string
  description = "Environment, e.g. 'load', 'zone', 'dev', 'uat'"
}

variable "resource" {
  type        = string
  description = "Solution name, e.g. 'app' or 'cluster'"
  default     = ""
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}
