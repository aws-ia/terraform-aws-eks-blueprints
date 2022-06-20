terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}

locals {
  launch_template_config = defaults(var.launch_template_config, {
    ami                    = ""
    launch_template_os     = "amazonlinux2eks" #bottlerocket
    launch_template_prefix = ""
    instance_type          = ""
    capacity_type          = ""
    iam_instance_profile   = ""
    vpc_security_group_ids = ""

    network_interfaces = {
      public_ip       = false
      security_groups = ""
    }

    block_device_mappings = {
      device_name           = "/dev/xvda"
      volume_type           = "gp3" # The volume type. Can be standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp3).
      volume_size           = 200
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = ""
      iops                  = 3000
      throughput            = 125
    }

    pre_userdata         = ""
    bootstrap_extra_args = ""
    post_userdata        = ""
    kubelet_extra_args   = ""

    service_ipv6_cidr      = ""
    service_ipv4_cidr      = ""
    format_mount_nvme_disk = false

    monitoring              = true
    enable_metadata_options = true
  })
}
