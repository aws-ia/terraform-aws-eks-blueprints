variable "launch_template_config" {
  description = "Launch template configuration"
  type = map(object({
    ami                    = string
    launch_template_os     = string
    launch_template_prefix = string
    instance_type          = string
    capacity_type          = string
    iam_instance_profile   = string
    vpc_security_group_ids = list(string) # conflicts with network_interfaces

    network_interfaces = list(object(
      public_ip       = bool
      security_groups = list(string)
    })))

    block_device_mappings = list(object({
      device_name           = string
      volume_type           = string
      volume_size           = string
      delete_on_termination = bool
      encrypted             = bool
      kms_key_id            = string
      iops                  = string
      throughput            = string
    }))

    format_mount_nvme_disk = bool
    pre_userdata           = string
    bootstrap_extra_args   = string
    post_userdata          = string
    kubelet_extra_args     = string

    enable_metadata_options     = bool
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number

    service_ipv6_cidr = string
    service_ipv4_cidr = string

    monitoring = bool
  }))
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
