variable "eks_cluster_id" {
  description = "EKS Cluster name"
  type        = string
}

variable "instance_name" {
  description = "Instance name"
  type        = string
  default     = ""
}

variable "provisioner_name" {
  description = "Provisioner name"
  type        = string
}

variable "kubelet_configuration" {
  description = "Configuration of kubelet"
  type = object({
    clusterDNS       = optional(list(string))
    containerRuntime = optional(string)
  })
  default = {}
}

variable "cpu_limit" {
  description = "Karpenter will not provision new instances for this provisioner once CPU limit is hit"
  type        = string
  default     = "1000"
}

variable "memory_limit" {
  description = "Karpenter will not provision new instances for this provisioner once Memory limit is hit"
  type        = string
  default     = "1000Gi"
}

variable "labels" {
  description = "Provisioned nodes will have these labels"
  type        = map(any)
  default     = {}
}

variable "ami_family" {
  description = "AMI family for the provisioned nodes. Not used when using launch templates"
  type        = string
  default     = "AL2"
}

variable "ami_selector" {
  description = "Select AMIs to run on through tags"
  type        = map(any)
  default     = {}
}

variable "block_device_mappings" {
  description = "Controls the EBS volumes that attach to provisioned nodes. Not used when using launch templates"
  type = list(object({
    deviceName = optional(string)
    ebs = optional(object({
      deleteOnTermination = optional(bool)
      encrypted           = optional(bool)
      iops                = optional(number)
      kmsKeyID            = optional(string)
      snapshotID          = optional(string)
      throughput          = optional(number)
      volumeSize          = optional(string)
      volumeType          = optional(string)
    }))
  }))
  default = []
}

variable "extra_security_group_selectors" {
  description = "Additional tags to select security groups to attach"
  type        = map(any)
  default     = {}
}

variable "extra_subnet_selectors" {
  description = "Additional tags to select subnets to run instances in"
  type        = map(any)
  default     = {}
}

variable "extra_tags" {
  description = "Additional tags to apply to running instances"
  type        = map(any)
  default     = {}
}

variable "iam_instance_profile" {
  description = "Role to pass to provisioned instance. Not used when using launch templates"
  type        = string
  default     = null
}

variable "launch_template" {
  description = "Launch template that the provisioner should use"
  type        = string
  default     = ""
}

variable "metadata_options" {
  description = "Control exposure of the IMDS on EC2 instances"
  type        = map(any)
  default     = {}
}

variable "requirements" {
  description = "Requirements that constrain the parameters of provisioned nodes"
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  default = []
}

variable "startup_taints" {
  description = "Provisioned nodes will have these taints but pods do not need to tolerate these taints to be provisioned by this provisioner. These taints are expected to be temporary and some other entity (e.g. a DaemonSet) is responsible for removing the taint after it has finished initializing the node"
  type = list(object({
    key    = string
    effect = string
  }))
  default = []
}

variable "taints" {
  description = "Provisioned nodes will have these taints"
  type = list(object({
    key    = string
    effect = string
  }))
  default = []
}

variable "ttl_seconds_after_empty" {
  description = "How long after a node is empty will it be scaled down due to low utilization. If null, the feature is disabled."
  type        = number
  default     = 30
}

variable "ttl_seconds_until_expired" {
  description = "Amount of uptime until nodes expire. If null, the feature is disabled."
  type        = number
  default     = null
}

variable "user_data" {
  description = "User data that will be applied to worker nodes. Not used when using launch templates"
  type        = string
  default     = null
}
