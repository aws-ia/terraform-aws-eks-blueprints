provider "grafana" {
  url  = var.grafana_endpoint
  auth = var.grafana_api_key
}

variable "grafana_endpoint" {
  type = string
}

variable "grafana_api_key" {
  type = string
  # TODO: update api key to secret - pre-defined secrets manager key?
  sensitive   = true
  description = "Api key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "amp"
  is_default = true
  url        = module.aws-eks-accelerator-for-terraform.amazon_prometheus_workspace_endpoint
  json_data {
    http_method     = "POST"
    sigv4_auth      = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region    = data.aws_region.current.name
  }
}