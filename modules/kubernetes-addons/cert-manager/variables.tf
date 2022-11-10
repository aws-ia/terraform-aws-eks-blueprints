variable "helm_config" {
  description = "cert-manager Helm chart configuration"
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps."
  type        = bool
  default     = false
}

variable "irsa_policies" {
  description = "Additional IAM policies used for the add-on service account."
  type        = list(string)
  default     = []
}

variable "domain_names" {
  description = "Domain names of the Route53 hosted zone to use with cert-manager."
  type        = list(string)
  default     = []
}

variable "install_acme_issuers" {
  description = "Install ACME Cluster Issuers."
  type        = bool
  default     = true
}

variable "email" {
  description = "Email address for expiration emails from ACME."
  type        = string
  default     = ""
}

variable "addon_context" {
  description = "Input configuration for the addon"
  type = object({
    aws_caller_identity_account_id = string
    aws_caller_identity_arn        = string
    aws_eks_cluster_endpoint       = string
    aws_partition_id               = string
    aws_region_name                = string
    eks_cluster_id                 = string
    eks_oidc_issuer_url            = string
    eks_oidc_provider_arn          = string
    tags                           = map(string)
    irsa_iam_role_path             = string
    irsa_iam_permissions_boundary  = string
  })
}

variable "kubernetes_svc_image_pull_secrets" {
  description = "list(string) of kubernetes imagePullSecrets"
  type        = list(string)
  default     = []
}

variable "cluster_issuer_name" {
  description = "Name of cluster issuer and release"
  type        = string
  default     = "malmo"
}

variable "external_account_keyID" {
  description = "ID of the CA key that the External Account is bound to."
  type        = string
  default     = ""
}

variable "external_account_secret_key" {
  description = "Secret key of the CA that the External Account is bound to."
  type        = string
  default     = ""
}

variable "preferred_chain" {
  description = "Chain to use if the ACME server outputs multiple."
  type        = string
  default     = ""
}

variable "acme_server_url" {
  description = "The URL used to access the ACME server's 'directory' endpoint."
  type        = string
  default     = ""
}

variable "dns_region" {
  description = "DNS Region"
  type        = string
  default     = ""
}

variable "common_name" {
  description = "Common name to be used on the Certificate."
  type        = string
  default     = ""
}

variable "is_ca" {
  description = "IsCA will mark this Certificate as valid for certificate signing."
  type        = bool
  default     = true
}

variable "dns_names" {
  description = "DNSNames is a list of DNS subjectAltNames to be set on the Certificate."
  type        = list(string)
  default     = []
}

variable "hosted_zone_id" {
  description = "If set, the provider will manage only this zone in Route53 and will not do an lookup using the route53:ListHostedZonesByName api call."
  type        = string
  default     = ""
}