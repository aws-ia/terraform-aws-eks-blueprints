# AWS Launch Templates
This module used to create Launch Templates for Node groups or Karpenter.

## Usage
This example shows how to consume the `launch-templates` module. See this full [example](examples/karpenter/main.tf).

```hcl
module "launch_templates" {
  source                         = "aws-samples/aws-eks-accelerator-for-terraform//modules/launch-templates"
  tags                           = { Name = "terraform-ssp-eks"}
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
          volume_size = "200"
          iops = 100          # io1 and io2 -> Min: 100 IOPS, Max: 100000 IOPS (up to 1000 IOPS per GiB)
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
          volume_size = "200"
          iops = 3000             #gp3-> Min: 3000 IOPS, Max: 16000 IOPS.
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
          volume_size = "200"
          iops = 3000             # gp3 -> Min: 3000 IOPS, Max: 16000 IOPS.
          throughput = 1000       # gp3 -> 125 to 1000
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
          volume_size = "200"
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
          volume_size = "200"
        }
      ]
    },
  }
}
```


<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster name | `string` | n/a | yes |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | Whether the Instance Metadata Service (IMDS) is available. Supported values: enabled, disabled | `string` | `"enabled"` | no |
| <a name="input_http_put_response_hop_limit"></a> [http\_put\_response\_hop\_limit](#input\_http\_put\_response\_hop\_limit) | HTTP PUT response hop limit for instance metadata requests. Supported values: 1-64. | `number` | `1` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | If enabled, will use Instance Metadata Service Version 2 (IMDSv2). Supported values: optional, required. | `string` | `"optional"` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM instance profile for Launch Templates | `string` | n/a | yes |
| <a name="input_launch_template_config"></a> [launch\_template\_config](#input\_launch\_template\_config) | n/a | <pre>map(object({<br>    ami                = string<br>    launch_template_os = optional(string)<br>    launch_template_id = string<br>    block_device_mappings = list(object({<br>      device_name           = string<br>      volume_type           = string<br>      volume_size           = string<br>      delete_on_termination = optional(bool)<br>      encrypted             = optional(bool)<br>      kms_key_id            = optional(string)<br>      iops                  = optional(number)<br>      throughput            = optional(number)<br>    }))<br>    pre_userdata         = optional(string)<br>    bootstrap_extra_args = optional(string)<br>    post_userdata        = optional(string)<br>    kubelet_extra_args   = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_worker_security_group_id"></a> [worker\_security\_group\_id](#input\_worker\_security\_group\_id) | Worker group security ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | Launch Template ARNs |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | Launch Template IDs |
| <a name="output_launch_template_image_id"></a> [launch\_template\_image\_id](#output\_launch\_template\_image\_id) | Launch Template Image IDs |
| <a name="output_launch_template_name"></a> [launch\_template\_name](#output\_launch\_template\_name) | Launch Template Names |

<!--- END_TF_DOCS --->
