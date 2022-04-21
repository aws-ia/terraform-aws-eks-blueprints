locals {
  default_managed_ng = {
    node_group_name          = "m5_on_demand" # Max node group length is 40 characters; including the node_group_name_prefix random id it's 63
    enable_node_group_prefix = true
    instance_types           = ["m5.large"]
    capacity_type            = "ON_DEMAND"  # ON_DEMAND, SPOT
    ami_type                 = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, BOTTLEROCKET_x86_64, BOTTLEROCKET_ARM_64
    subnet_type              = "private"
    subnet_ids               = []
    release_version          = ""
    force_update_version     = null

    desired_size    = "3"
    max_size        = "3"
    min_size        = "1"
    max_unavailable = "1"
    disk_size       = 50 # disk_size will be ignored when using Launch Templates

    k8s_labels      = {}
    k8s_taints      = []
    additional_tags = {}

    remote_access           = false
    ec2_ssh_key             = ""
    ssh_security_group_id   = ""
    additional_iam_policies = []

    timeouts = [{
      create = "30m"
      update = "2h"
      delete = "30m"
    }]

    # The following defaults used only when you enable Launch Templates e.g., create_launch_template=true
    # LAUNCH TEMPLATES
    custom_ami_id          = ""
    create_launch_template = false
    enable_monitoring      = true
    launch_template_os     = "amazonlinux2eks" # amazonlinux2eks/bottlerocket # Used to identify the launch template
    pre_userdata           = ""
    post_userdata          = ""
    kubelet_extra_args     = ""
    bootstrap_extra_args   = ""
    public_ip              = false

    # EBS Block Device config only used with Launch Templates
    block_device_mappings = [{
      device_name           = "/dev/xvda"
      volume_type           = "gp3" # The volume type. Can be standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp3).
      volume_size           = "100"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = ""
      iops                  = 3000
      throughput            = 125
    }]
  }

  managed_node_group = merge(
    local.default_managed_ng,
    var.managed_ng
  )

  policy_arn_prefix = "arn:${var.context.aws_partition_id}:iam::aws:policy"
  ec2_principal     = "ec2.${var.context.aws_partition_dns_suffix}"

  userdata_params = {
    eks_cluster_id       = var.context.eks_cluster_id
    cluster_ca_base64    = var.context.cluster_ca_base64
    cluster_endpoint     = var.context.cluster_endpoint
    custom_ami_id        = local.managed_node_group["custom_ami_id"]
    pre_userdata         = local.managed_node_group["pre_userdata"]         # Applied to all launch templates
    bootstrap_extra_args = local.managed_node_group["bootstrap_extra_args"] # used only when custom_ami_id specified e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
    post_userdata        = local.managed_node_group["post_userdata"]        # used only when custom_ami_id specified
    kubelet_extra_args   = local.managed_node_group["kubelet_extra_args"]   # used only when custom_ami_id specified e.g., kubelet_extra_args="--node-labels=arch=x86,WorkerType=SPOT --max-pods=50 --register-with-taints=spot=true:NoSchedule"  # Equivalent to k8s_labels used in managed node groups
    service_ipv6_cidr    = var.context.service_ipv6_cidr == null ? "" : var.context.service_ipv6_cidr
    service_ipv4_cidr    = var.context.service_ipv4_cidr == null ? "" : var.context.service_ipv4_cidr
  }

  userdata_base64 = base64encode(
    templatefile("${path.module}/templates/userdata-${local.managed_node_group["launch_template_os"]}.tpl", local.userdata_params)
  )

  eks_worker_policies = toset(concat(
    local.managed_node_group["additional_iam_policies"]
  ))

  common_tags = merge(
    var.context.tags,
    local.managed_node_group["additional_tags"],
    {
      Name = "${var.context.eks_cluster_id}-${local.managed_node_group["node_group_name"]}"
    },
    {
      "kubernetes.io/cluster/${var.context.eks_cluster_id}"     = "owned"
      "k8s.io/cluster-autoscaler/${var.context.eks_cluster_id}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"                       = "TRUE"
  })
}
