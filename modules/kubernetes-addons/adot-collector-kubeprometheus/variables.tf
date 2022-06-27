
# Kube-state-metrics Variables
variable "enabled_kube_state_metrics" {
  description = "Variable indicating whether deployment is enabled"
  type        = bool
  default     = true
}


# Helm

variable "helm_create_namespace_ksm" {
  type        = bool
  default     = true
  description = "Create the namespace if it does not yet exist"
}

variable "helm_chart_name_ksm" {
  type        = string
  default     = "kube-state-metrics"
  description = "Helm chart name to be installed"
}

variable "helm_chart_version_ksm" {
  type        = string
  default     = "2.1.4"
  description = "Version of the Helm chart"
}

variable "helm_release_name_ksm" {
  type        = string
  default     = "kube-state-metrics"
  description = "Helm release name"
}

variable "helm_repo_url_ksm" {
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts"
  description = "Helm repository"
}

# K8s

variable "k8s_namespace_ksm" {
  type        = string
  default     = "kube-system"
  description = "The K8s namespace in which the prometheus-node-exporter service account has been created"
}

variable "settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values, see https://hub.helm.sh/charts/stable/prometheus-node-exporter"
}

variable "values" {
  type        = string
  default     = ""
  description = "Additional yaml encoded values which will be passed to the Helm chart."
}

# Node exporter Variables

variable "enabled_node_exporter" {
  description = "Variable indicating whether deployment is enabled"
  type        = bool
  default     = true
}

# Helm

variable "helm_create_namespace_ne" {
  type        = bool
  default     = true
  description = "Create the namespace if it does not yet exist"
}

variable "helm_chart_name_ne" {
  type        = string
  default     = "prometheus-node-exporter"
  description = "Helm chart name to be installed"
}

variable "helm_chart_version_ne" {
  type        = string
  default     = "2.0.3"
  description = "Version of the Helm chart"
}

variable "helm_release_name_ne" {
  type        = string
  default     = "prometheus-node-exporter"
  description = "Helm release name"
}

variable "helm_repo_url_ne" {
  type        = string
  default     = "https://prometheus-community.github.io/helm-charts"
  description = "Helm repository"
}

# K8s

variable "k8s_namespace_ne" {
  type        = string
  default     = "kube-system"
  description = "The K8s namespace in which the prometheus-node-exporter service account has been created"
}
