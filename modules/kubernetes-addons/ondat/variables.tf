variable "helm_config" {
  description = "Helm provider config for the ondat addon"
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps"
  type        = bool
  default     = false
}

variable "addon_context" {
  description = "Input configuration for the addon"
  type        = any
}

variable "irsa_permissions_boundary" {
  description = "IAM Policy ARN for IRSA IAM role permissions boundary"
  type        = string
  default     = ""
}

variable "irsa_policies" {
  description = "IAM policy ARNs for Ondat IRSA"
  type        = list(string)
  default     = []
}

variable "create_cluster" {
  description = "Determines if the StorageOSCluster and secrets should be created"
  type        = bool
  default     = true
}

variable "etcd_endpoints" {
  description = "A list of etcd endpoints for Ondat"
  type        = list(string)
  default     = []
}

variable "etcd_ca" {
  description = "The PEM encoded CA for Ondat's etcd"
  type        = string
  default     = null
}

variable "etcd_cert" {
  description = "The PEM encoded client certificate for Ondat's etcd"
  type        = string
  default     = null
}

variable "etcd_key" {
  description = "The PEM encoded client key for Ondat's etcd"
  type        = string
  default     = null
  sensitive   = true
}

variable "admin_username" {
  description = "Username for the Ondat admin user"
  type        = string
  default     = "storageos"
}

variable "admin_password" {
  description = "Password for the Ondat admin user"
  type        = string
  default     = "storageos"
  sensitive   = true
}
