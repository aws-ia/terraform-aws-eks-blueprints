variable "grafana_endpoint" {
  description = "Grafana endpoint"
  type        = string
  default     = "https://g-c8c277d21b.grafana-workspace.us-east-1.amazonaws.com"
}

variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = "eyJrIjoiZHpBdGM5cGRJa29WRjN6TG52aHhQUUJwa3pHSjhKQ3MiLCJuIjoiYWRtaW4iLCJpZCI6MX0="
  sensitive   = true
}

variable "eks_cluster" {
  description = "EKS CLuster Name"
  type       = string
  default   = "eksworkshop-eksctl"
}
variable "aws_region" {
  description = "AWS Region"
  type       = string
  default    = "us-east-1"
}
