locals {
  # ami_id = var.self_managed_ng["custom_ami_type"] == "bottlerocket" ? data.aws_ssm_parameter.bottlerocket_ami_id.value : data.aws_ssm_parameter.amazonlinux2eks_ami_id.value

  predefined_custom_ami_types = tolist(["amazonlinux2eks", "bottlerocket", "windows"])

  userdata_base64 = {
    for custom_ami_type in local.predefined_custom_ami_types : custom_ami_type => base64encode(
      templatefile(
        "${path.module}/templates/userdata-${custom_ami_type}.tpl",
        local.userdata_params
      )
    )
  }

  custom_userdata_base64 = contains(local.predefined_custom_ami_types, var.self_managed_ng["os_ami_type"]) ? local.userdata_base64[var.self_managed_ng["os_ami_type"]] : null

  userdata_params = {
    cluster_name               = var.cluster_full_name
    cluster_ca_base64          = var.cluster_ca
    cluster_endpoint           = var.cluster_endpoint
    kubelet_extra_args         = var.self_managed_ng["kubelet_extra_args"] != "" ? var.self_managed_ng["kubelet_extra_args"] : ""
    bootstrap_extra_args       = var.self_managed_ng["bootstrap_extra_args"] != "" ? var.self_managed_ng["bootstrap_extra_args"] : ""
    self_managed_node_userdata = var.self_managed_ng["self_managed_node_userdata"]
  }

  self_managed_node_ami_id        = var.self_managed_ng["self_managed_node_ami_id"]
  self_managed_node_desired_size  = var.self_managed_ng["self_managed_node_desired_size"]
  self_managed_node_instance_type = var.self_managed_ng["self_managed_node_instance_type"]
  self_managed_capacity_type      = var.self_managed_ng["capacity_type"] == "spot" ? "spot" : ""
  self_managed_node_max_size      = var.self_managed_ng["self_managed_node_max_size"]
  self_managed_node_min_size      = var.self_managed_ng["self_managed_node_min_size"]
  self_managed_node_volume_size   = var.self_managed_ng["self_managed_node_volume_size"]
  self_managed_nodegroup_name     = var.self_managed_ng["self_managed_nodegroup_name"]
  custom_security_group_id        = var.self_managed_ng["self_managed_custom_security_group_id"]
  policy_arn_prefix               = "arn:aws:iam::aws:policy"

  subnet_ids = var.self_managed_ng["subnet_ids"] == [] ? var.self_managed_ng["subnet_type"] == "public" ? var.self_managed_public_subnet_ids : var.self_managed_private_subnet_ids : var.self_managed_ng["subnet_ids"]


  common_tags = {
    Name                                                 = "${var.cluster_full_name}-self-managed-workers"
    "k8s.io/cluster-autoscaler/${var.cluster_full_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"                  = "TRUE"
    "kubernetes.io/cluster/${var.cluster_full_name}"     = "owned"
    "ControlledBy"                                       = "terraform"
  }

}
