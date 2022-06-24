variable "managed_ng" {
  description = "Map of maps of `eks_node_groups` to create"
  type        = any
  default     = {}
}

variable "context" {
  description = "Input configuration for the Node groups"
  type = object({
    # EKS Cluster Config
    eks_cluster_id    = string
    cluster_ca_base64 = string
    cluster_endpoint  = string
    cluster_version   = string
    # VPC Config
    vpc_id             = string
    private_subnet_ids = list(string)
    public_subnet_ids  = list(string)
    # Security Groups
    worker_security_group_ids = list(string)

    # Data sources
    aws_partition_dns_suffix = string
    aws_partition_id         = string
    #IAM
    iam_role_path                 = string
    iam_role_permissions_boundary = string
    # Tags
    tags = map(string)
    # Service IPV4/IPV6 CIDR
    service_ipv6_cidr = string
    service_ipv4_cidr = string
  })
}
