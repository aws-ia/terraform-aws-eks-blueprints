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
      volume_type           = "gp2" # The volume type. Can be standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp2).
      volume_size           = "200"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = "" # The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set
      iops                  = "" # The amount of provisioned IOPS. This must be set with a volume_type of "io1/io2"
      throughput            = "" # The throughput to provision for a gp3 volume in MiB/s (specified as an integer, e.g., 500), with a maximum of 1,000 MiB/s
    }
    pre_userdata         = ""
    bootstrap_extra_args = ""
    post_userdata        = ""
    kubelet_extra_args   = ""
  })
}
