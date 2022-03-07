variable "managed_ng" {
  description = "Map of maps of `eks_node_groups` to create"
  type        = any
  default     = {}
}

variable "path" {
  type        = string
  default     = "/"
  description = "IAM resource path, e.g. /dev/"
}

variable "context" {
  type = object({
    # EKS Cluster Config
    eks_cluster_id     = string
    cluster_ca_base64  = string
    cluster_endpoint   = string
    kubernetes_version = string
    # VPC Config
    vpc_id             = string
    private_subnet_ids = list(string)
    public_subnet_ids  = list(string)
    # Security Groups
    worker_security_group_id             = string
    worker_additional_security_group_ids = list(string)
    cluster_security_group_id            = string
    cluster_primary_security_group_id    = string
    # Http config
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
    # Data sources
    aws_partition_dns_suffix = string
    aws_partition_id         = string
    # Tags
    tags = map(string)
  })
  description = "Input configuration for the Node groups"
}
