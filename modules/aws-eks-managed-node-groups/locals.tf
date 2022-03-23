locals {
  default_managed_ng = {
    node_group_name          = "m5_on_demand" # Max node group length is 40 characters; including the node_group_name_prefix random id it's 63
    enable_node_group_prefix = true
    instance_types           = ["m5.large"]
    capacity_type            = "ON_DEMAND"  # ON_DEMAND, SPOT
    ami_type                 = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, BOTTLEROCKET_x86_64, BOTTLEROCKET_ARM_64
    custom_ami_id            = ""
    subnet_type              = "private"
    subnet_ids               = []
    release_version          = ""

    desired_size    = "3"
    max_size        = "3"
    min_size        = "1"
    max_unavailable = "1"

    disk_size = 50
    disk_type = "gp3"

    enable_monitoring = true
    eni_delete        = true
    public_ip         = false

    k8s_labels      = {}
    k8s_taints      = []
    additional_tags = {}

    # LAUNCH TEMPLATES
    create_launch_template  = false
    launch_template_os      = "amazonlinux2eks" # amazonlinux2eks/bottlerocket # Used to identify the launch template
    pre_userdata            = ""
    post_userdata           = ""
    kubelet_extra_args      = ""
    bootstrap_extra_args    = ""
    launch_template_id      = null
    launch_template_version = "$Latest"

    # SSH ACCESS
    remote_access           = false
    ec2_ssh_key             = ""
    ssh_security_group_id   = ""
    additional_iam_policies = []

    timeouts = [{
      create = "30m"
      update = "2h"
      delete = "30m"
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
    bootstrap_extra_args = local.managed_node_group["bootstrap_extra_args"]
    pre_userdata         = local.managed_node_group["pre_userdata"]
    post_userdata        = local.managed_node_group["post_userdata"]
    kubelet_extra_args   = local.managed_node_group["kubelet_extra_args"]
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
