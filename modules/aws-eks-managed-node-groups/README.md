



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| [aws_eks_node_group.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_instance_profile.mg_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.eks_autoscaler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.mg_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.mg_linux_AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.mg_linux_AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.mg_linux_AmazonEKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.mg_linux_AmazonPrometheusRemoteWriteAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.mg_linux_AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.mg_linux_CloudWatchFullAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.mg_linux_ElasticLoadBalancingFullAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.mg_linux_cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.managed_node_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.mg_linux_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_managed_prometheus_enable"></a> [aws\_managed\_prometheus\_enable](#input\_aws\_managed\_prometheus\_enable) | Enable AWS-managed Prometheus | `bool` | `false` | no |
| <a name="input_cluster_autoscaler_enable"></a> [cluster\_autoscaler\_enable](#input\_cluster\_autoscaler\_enable) | Enable AWS-managed Prometheus | `bool` | `false` | no |
| <a name="input_cluster_ca_base64"></a> [cluster\_ca\_base64](#input\_cluster\_ca\_base64) | Base64-encoded cluster certificate-authority-data | `string` | `""` | no |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Cluster K8s API server endpoint | `string` | `""` | no |
| <a name="input_create_eks"></a> [create\_eks](#input\_create\_eks) | Controls if EKS resources should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_managed_ng"></a> [managed\_ng](#input\_managed\_ng) | Map of maps of `eks_node_groups` to create | `any` | `{}` | no |
| <a name="input_path"></a> [path](#input\_path) | IAM resource path, e.g. /dev/ | `string` | `"/"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | list of private subnets Id's for the Worker nodes | `list` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | list of public subnets Id's for the Worker nodes | `list` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_use_custom_ami"></a> [use\_custom\_ami](#input\_use\_custom\_ami) | Use custom AMI | `bool` | `false` | no |
| <a name="input_worker_additional_security_group_ids"></a> [worker\_additional\_security\_group\_ids](#input\_worker\_additional\_security\_group\_ids) | A list of additional security group ids to attach to worker instances | `list(string)` | `[]` | no |
| <a name="input_worker_security_group_id"></a> [worker\_security\_group\_id](#input\_worker\_security\_group\_id) | Worker group security ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_launch_template_ids"></a> [launch\_template\_ids](#output\_launch\_template\_ids) | n/a |
| <a name="output_launch_template_latest_versions"></a> [launch\_template\_latest\_versions](#output\_launch\_template\_latest\_versions) | n/a |
| <a name="output_mg_linux_roles"></a> [mg\_linux\_roles](#output\_mg\_linux\_roles) | Linux node IAM role |
| <a name="output_node_groups"></a> [node\_groups](#output\_node\_groups) | Outputs from EKS node groups |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

