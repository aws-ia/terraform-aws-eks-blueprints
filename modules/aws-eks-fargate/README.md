


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
| [aws_eks_fargate_profile.eks-fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_fargate_profile) | resource |
| [aws_iam_role.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.fargate-AmazonEKSFargatePodExecutionRolePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.fargate_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_ca_base64"></a> [cluster\_ca\_base64](#input\_cluster\_ca\_base64) | Base64-encoded cluster certificate-authority-data | `string` | `""` | no |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Cluster K8s API server endpoint | `string` | `""` | no |
| <a name="input_create_eks"></a> [create\_eks](#input\_create\_eks) | Controls if EKS resources should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_enable_fargate"></a> [enable\_fargate](#input\_enable\_fargate) | n/a | `bool` | `false` | no |
| <a name="input_fargate_profile"></a> [fargate\_profile](#input\_fargate\_profile) | Map of maps of `eks_node_groups` to create | `any` | `{}` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | list of private subnets Id's for the Worker nodes | `list` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | list of public subnets Id's for the Worker nodes | `list` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_worker_additional_security_group_ids"></a> [worker\_additional\_security\_group\_ids](#input\_worker\_additional\_security\_group\_ids) | A list of additional security group ids to attach to worker instances | `list(string)` | `[]` | no |
| <a name="input_worker_security_group_id"></a> [worker\_security\_group\_id](#input\_worker\_security\_group\_id) | Worker group security ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_fargate_profile_id"></a> [eks\_fargate\_profile\_id](#output\_eks\_fargate\_profile\_id) | EKS Cluster name and EKS Fargate Profile name separated by a colon |
| <a name="output_eks_fargate_profile_role_name"></a> [eks\_fargate\_profile\_role\_name](#output\_eks\_fargate\_profile\_role\_name) | Name of the EKS Fargate Profile IAM role |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

