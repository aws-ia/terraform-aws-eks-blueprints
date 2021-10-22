
locals {
  default_managed_ng = {
    node_group_name = "m4_on_demand" # Max node group length is 40 characters; including the node_group_name_prefix random id it's 63
    instance_types  = ["m4.large"]
    capacity_type   = "ON_DEMAND"  # ON_DEMAND, SPOT
    ami_type        = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
    custom_ami_id   = ""           # Used only with Bottlerocket with custom AMI id
    subnet_ids      = []

    desired_size    = "3"
    max_size        = "3"
    min_size        = "1"
    max_unavailable = "1"

    disk_size = 50
    disk_type = "gp2"

    enable_monitoring = true
    eni_delete        = true
    public_ip         = false

    k8s_labels      = {}
    k8s_taints      = []
    additional_tags = {}

    create_worker_security_group = false

    # LAUNCH TEMPLATES
    create_launch_template  = false
    launch_template_os      = "amazonlinux2eks" # amazonlinux2eks/bottlerocket # Used to identify the launch template
    pre_userdata            = ""
    post_userdata           = ""
    launch_template_id      = null
    launch_template_version = "$Latest"
    kubelet_extra_args      = ""
    bootstrap_extra_args    = ""

    # SSH ACCESS
    remote_access         = false
    ec2_ssh_key           = ""
    ssh_security_group_id = ""
  }
  managed_node_group = merge(
    local.default_managed_ng,
    var.managed_ng
  )

  policy_arn_prefix = "arn:aws:iam::aws:policy"
  ec2_principal     = "ec2.${data.aws_partition.current.dns_suffix}"

  userdata_params = {
    cluster_name         = var.eks_cluster_name
    cluster_ca_base64    = var.cluster_ca_base64
    cluster_endpoint     = var.cluster_endpoint
    bootstrap_extra_args = local.managed_node_group["bootstrap_extra_args"]
    pre_userdata         = local.managed_node_group["pre_userdata"]
    post_userdata        = local.managed_node_group["post_userdata"]
    kubelet_extra_args   = local.managed_node_group["kubelet_extra_args"]
  }

  userdata_base64 = base64encode(
    templatefile("${path.module}/templates/userdata-${local.managed_node_group["launch_template_os"]}.tpl", local.userdata_params)
  )

  common_tags = merge(
    var.tags,
    {
      Name = "${var.eks_cluster_name}-${local.managed_node_group["node_group_name"]}"
    },
    {
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  })

}
