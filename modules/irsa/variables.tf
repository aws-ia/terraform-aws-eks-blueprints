variable "kubernetes_namespace" {
  description = "Kubernetes Namespace name"
  type        = string
}

variable "create_kubernetes_namespace" {
  description = "Should the module create the namespace"
  type        = bool
  default     = true
}

variable "create_kubernetes_service_account" {
  description = "Should the module create the Service Account"
  type        = bool
  default     = true
}

variable "create_service_account_secret_token" {
  description = "Should the module create a secret for the service account (from k8s version 1.24 service account doesn't automatically create secret of the token)"
  type        = bool
  default     = false
}

variable "kubernetes_service_account" {
  description = "Kubernetes Service Account Name"
  type        = string
}

variable "kubernetes_svc_image_pull_secrets" {
  description = "list(string) of kubernetes imagePullSecrets"
  type        = list(string)
  default     = []
}

variable "irsa_iam_policies" {
  type        = list(string)
  description = "IAM Policies for IRSA IAM role"
  default     = []
}

variable "irsa_iam_role_name" {
  type        = string
  description = "IAM role name for IRSA"
  default     = ""
}

variable "irsa_iam_role_path" {
  description = "IAM role path for IRSA roles"
  type        = string
  default     = "/"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = ""
}

variable "irsa_principal_role_arn" {
  description = "IRSA IAM Role ARN to be used in the trust policy e.g., arn:aws:iam::<ACCOUNT-ID>:role/EMR_EC2_DefaultRole"
  type        = string
  default     = null
}

variable "irsa_principal_role_service" {
  description = "IRSA IAM Role Service to be used in the trust policy e.g., eks.amazonaws.com"
  type        = string
  default     = null
}

variable "irsa_role_additional_actions" {
  description = "Additional IRSA IAM Role Actions to be added to the policy"
  type        = list(string)
  default     = []
}

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN e.g., arn:aws:iam::<ACCOUNT-ID>:oidc-provider/<var.eks_oidc_provider>"
  type        = string
}

variable "eks_cluster_id" {
  description = "EKS Cluster ID"
  type        = string
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
