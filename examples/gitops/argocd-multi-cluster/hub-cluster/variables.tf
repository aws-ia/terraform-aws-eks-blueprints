variable "domain_private_zone" {
  description = "Is ArgoCD private zone"
  type        = bool
  default     = false
}

variable "argocd_sso_cli_client_id" {
  description = "ArgoCD SSO OIDC cliClientID"
  type        = string
  default     = ""
}

variable "argocd_sso_client_id" {
  description = "ArgoCD SSO OIDC clientID"
  type        = string
  default     = ""
}

variable "argocd_enable_sso" {
  description = "Enable SSO for ArgoCD"
  type        = bool
  default     = false
}

variable "argocd_sso_client_secret" {
  description = "ArgoCD SSO OIDC clientSecret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_sso_issuer" {
  description = "ArgoCD SSO OIDC issuer"
  type        = string
  default     = ""
}

variable "argocd_sso_logout_url" {
  description = "ArgoCD SSO OIDC logoutURL"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain Name"
  type        = string
  default     = ""
}

variable "enable_ingress" {
  description = "Enable ingress"
  type        = bool
  default     = false
}

variable "hub_cluster_name" {
  description = "Hub Cluster Name"
  type        = string
  default     = "hub-cluster"
}

variable "hub_profile" {
  description = "Hub Cluster CLI Profile"
  type        = string
  default     = "default"
}

variable "region" {
  description = "Hub Cluster Region"
  type        = string
  default     = "us-west-2"
}
