## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.49.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_launch_template.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [template_file.launch_template_bottle_rocket_userdata](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.launch_template_userdata](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_ca_base64"></a> [cluster\_ca\_base64](#input\_cluster\_ca\_base64) | n/a | `any` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | n/a | `any` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `any` | n/a | yes |
| <a name="input_custom_ami_id"></a> [custom\_ami\_id](#input\_custom\_ami\_id) | Custom AMI ID, e.g. /aws/service/bottlerocket/aws-k8s-1.20/x86\_64/latest/image\_id | `string` | `null` | no |
| <a name="input_node_group_name"></a> [node\_group\_name](#input\_node\_group\_name) | n/a | `any` | n/a | yes |
| <a name="input_public_launch_template"></a> [public\_launch\_template](#input\_public\_launch\_template) | n/a | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `any` | n/a | yes |
| <a name="input_use_custom_ami"></a> [use\_custom\_ami](#input\_use\_custom\_ami) | n/a | `bool` | `false` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | variable "instance\_type" {} | `string` | `"50"` | no |
| <a name="input_worker_security_group_id"></a> [worker\_security\_group\_id](#input\_worker\_security\_group\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | n/a |
| <a name="output_launch_template_latest_version"></a> [launch\_template\_latest\_version](#output\_launch\_template\_latest\_version) | n/a |
