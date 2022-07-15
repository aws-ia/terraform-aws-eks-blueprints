# AWS Launch Templates

This module used to create Launch Templates for Node groups or Karpenter.

## Usage

This example shows how to consume the `launch-templates` module. See this full [example](../../examples/karpenter/main.tf).

```hcl
module "launch_templates" {
  source                         = "aws-ia/terraform-aws-eks-blueprints//modules/launch-templates"
  tags                           = { Name = "eks-blueprints"}
  eks_cluster_id                 = "<Enter EKS CLuster ID>"

  launch_template_config = {
    io1 = {
      ami                         = "ami-0adc757be1e4e11a1"
      launch_template_prefix      = "io1"
      launch_template_os          = "amazonlinux2eks"
      vpc_security_group_ids      = "<comma separated security groups ids>"
      iam_instance_profile        = "IAM Instance Profile"
      block_device_mappings       = [
        {
          device_name = "/dev/xvda"
          volume_type = "io1"
          volume_size = 200
          iops = 100               # io1 and io2 -> Min: 100 IOPS, Max: 100000 IOPS (up to 1000 IOPS per GiB)
        }
      ]
    },
    io2 = {
      ami                          = "ami-0adc757be1e4e11a1"
      launch_template_prefix       = "io2"
      launch_template_os           = "amazonlinux2eks"
      vpc_security_group_ids       = "<comma separated security groups ids>"
      iam_instance_profile         = "IAM Instance Profile"
      block_device_mappings        = [
        {
          device_name = "/dev/xvda"
          volume_type = "io2"
          volume_size = 200
          iops = 3000              #gp3-> Min: 3000 IOPS, Max: 16000 IOPS.
        }
      ]
    },
    gp3 = {
      ami                          = "ami-0adc757be1e4e11a1"
      launch_template_prefix       = "gp3"
      launch_template_os           = "amazonlinux2eks"
      vpc_security_group_ids       = "<comma separated security groups ids>"
      iam_instance_profile         = "IAM Instance Profile"
      block_device_mappings        = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp3"
          volume_size = 200
          iops        = 3000       # gp3 -> Min: 3000 IOPS, Max: 16000 IOPS.
          throughput  = 1000       # gp3 -> 125 to 1000
        }
      ]
    },
    gp2 = {
      ami = "ami-0adc757be1e4e11a1"
      ami                          = "ami-0adc757be1e4e11a1"
      launch_template_prefix       = "gp2"
      launch_template_os           = "amazonlinux2eks"
      vpc_security_group_ids       = "<comma separated security groups ids>"
      iam_instance_profile         = "IAM Instance Profile"
      block_device_mappings        = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp2"
          volume_size = 200
        }
      ]
    },
    bottlerocket = {
      ami                           = "ami-03909df9bfcc1e215"
      launch_template_os            = "bottlerocket"
      launch_template_prefix        = "bottle"
      vpc_security_group_ids        = "<comma separated security groups ids>"
      iam_instance_profile          = "IAM Instance Profile"
      block_device_mappings         = [
        {
          device_name = "/dev/xvda"
          volume_type = "gp2"
          volume_size = 200
        }
      ]
    },
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster ID | `string` | n/a | yes |
| <a name="input_launch_template_config"></a> [launch\_template\_config](#input\_launch\_template\_config) | Launch template configuration | <pre>map(object({<br>    ami                    = string<br>    launch_template_os     = optional(string)<br>    launch_template_prefix = string<br>    instance_type          = optional(string)<br>    capacity_type          = optional(string)<br>    iam_instance_profile   = optional(string)<br>    vpc_security_group_ids = optional(list(string)) # conflicts with network_interfaces<br><br>    network_interfaces = optional(list(object({<br>      public_ip       = optional(bool)<br>      security_groups = optional(list(string))<br>    })))<br><br>    block_device_mappings = list(object({<br>      device_name           = string<br>      volume_type           = string<br>      volume_size           = string<br>      delete_on_termination = optional(bool)<br>      encrypted             = optional(bool)<br>      kms_key_id            = optional(string)<br>      iops                  = optional(string)<br>      throughput            = optional(string)<br>    }))<br><br>    format_mount_nvme_disk = optional(bool)<br>    pre_userdata           = optional(string)<br>    bootstrap_extra_args   = optional(string)<br>    post_userdata          = optional(string)<br>    kubelet_extra_args     = optional(string)<br><br>    enable_metadata_options     = optional(bool)<br>    http_endpoint               = optional(string)<br>    http_tokens                 = optional(string)<br>    http_put_response_hop_limit = optional(number)<br>    http_protocol_ipv6          = optional(string)<br>    instance_metadata_tags      = optional(string)<br><br>    service_ipv6_cidr = optional(string)<br>    service_ipv4_cidr = optional(string)<br><br>    monitoring = optional(bool)<br>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | Launch Template ARNs |
| <a name="output_launch_template_default_version"></a> [launch\_template\_default\_version](#output\_launch\_template\_default\_version) | Launch Template Default Versions |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | Launch Template IDs |
| <a name="output_launch_template_image_id"></a> [launch\_template\_image\_id](#output\_launch\_template\_image\_id) | Launch Template Image IDs |
| <a name="output_launch_template_latest_version"></a> [launch\_template\_latest\_version](#output\_launch\_template\_latest\_version) | Launch Template Latest Versions |
| <a name="output_launch_template_name"></a> [launch\_template\_name](#output\_launch\_template\_name) | Launch Template Names |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
