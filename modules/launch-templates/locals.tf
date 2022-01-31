terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}

locals {
  launch_template_config = defaults(var.launch_template_config, {
    ami                = ""
    launch_template_os = "amazonlinux2eks" #bottlerocket
    launch_template_id = ""
    block_device_mappings = {
      device_name           = "/dev/xvda"
      disk_type             = "gp2"
      disk_size             = "200"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = ""
    }
    pre_userdata         = ""
    bootstrap_extra_args = ""
    post_userdata        = ""
    kubelet_extra_args   = ""
  })
}
