
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.59.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_node_group.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_instance_profile.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.eks_autoscaler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.managed_ng_AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_ng_AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_ng_AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_ng_AmazonPrometheusRemoteWriteAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_ng_AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_ng_CloudWatchFullAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_ng_ElasticLoadBalancingFullAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed_ng_cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.managed_node_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.masters_api_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.masters_kubelet_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.masters_kubelet_https_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.masters_workers_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_to_worker_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_to_worker_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.workers_masters_https_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.workers_masters_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.managed_ng_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_ca_base64"></a> [cluster\_ca\_base64](#input\_cluster\_ca\_base64) | Base64-encoded EKS cluster certificate-authority-data | `string` | `""` | no |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | EKS Cluster K8s API server endpoint | `string` | `""` | no |
| <a name="input_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#input\_cluster\_primary\_security\_group\_id) | Cluster Primary security group ID for self managed node group | `string` | `""` | no |
| <a name="input_create_eks"></a> [create\_eks](#input\_create\_eks) | Controls if EKS resources should be created | `bool` | `true` | no |
| <a name="input_default_worker_security_group_id"></a> [default\_worker\_security\_group\_id](#input\_default\_worker\_security\_group\_id) | Worker group security ID | `string` | `""` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | EKS Cluster name | `string` | n/a | yes |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | Whether the Instance Metadata Service (IMDS) is available. Supported values: enabled, disabled | `string` | `"enabled"` | no |
| <a name="input_http_put_response_hop_limit"></a> [http\_put\_response\_hop\_limit](#input\_http\_put\_response\_hop\_limit) | HTTP PUT response hop limit for instance metadata requests. Supported values: 1-64. | `number` | `1` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | If enabled, will use Instance Metadata Service Version 2 (IMDSv2). Supported values: optional, required. | `string` | `"optional"` | no |
| <a name="input_managed_ng"></a> [managed\_ng](#input\_managed\_ng) | Map of maps of `eks_node_groups` to create | `any` | `{}` | no |
| <a name="input_path"></a> [path](#input\_path) | IAM resource path, e.g. /dev/ | `string` | `"/"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | list of private subnets Id's for the Worker nodes | `list` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | list of public subnets Id's for the Worker nodes | `list` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_use_custom_ami"></a> [use\_custom\_ami](#input\_use\_custom\_ami) | Use custom AMI | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |
| <a name="input_worker_additional_security_group_ids"></a> [worker\_additional\_security\_group\_ids](#input\_worker\_additional\_security\_group\_ids) | A list of additional security group ids to attach to worker instances | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | launch templated id for EKS Self Managed Node Group |
| <a name="output_launch_template_ids"></a> [launch\_template\_ids](#output\_launch\_template\_ids) | launch templated id for EKS Managed Node Group |
| <a name="output_launch_template_latest_versions"></a> [launch\_template\_latest\_versions](#output\_launch\_template\_latest\_versions) | launch templated version for EKS Managed Node Group |
| <a name="output_manage_ng_iam_role_arn"></a> [manage\_ng\_iam\_role\_arn](#output\_manage\_ng\_iam\_role\_arn) | IAM role ARN for EKS Managed Node Group |
| <a name="output_manage_ng_iam_role_name"></a> [manage\_ng\_iam\_role\_name](#output\_manage\_ng\_iam\_role\_name) | n/a |
| <a name="output_node_groups"></a> [node\_groups](#output\_node\_groups) | EKS Managed node group id |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

