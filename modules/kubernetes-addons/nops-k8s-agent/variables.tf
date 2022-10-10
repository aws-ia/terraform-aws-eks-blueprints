variable "helm_config" {
  description = "Helm provider config for nops-k8s-agent."
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps."
  type        = bool
  default     = false
}

variable "irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "app_nops_k8s_collector_api_key" {
  description = "NOPS api key"
  type        = string
}

variable "app_nops_k8s_collector_aws_account_number" {
  description = "NOPS collector aws account number"
  type        = number
}

variable "app_prometheus_server_endpoint" {
  description = " Prometheus server endpoint"
  default     = ""
  type        = string
}
variable "app_nops_k8s_agent_clusterid" {
  description = "NOPS agent cluster id"
  type        = any
}
variable "app_nops_k8s_collector_skip_ssl" {
  description = "NOPS collector aws account number"
  type        = any
}

variable "app_nops_k8s_agent_prom_token" {
  description = "App nops agent prometheus token"
  default     = {}
  type        = any


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
