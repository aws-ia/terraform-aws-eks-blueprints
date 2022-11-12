# AWS Node Termination handler Helm Chart

## What is aws-node-termination-handler

[aws-node-termination-handler](https://github.com/aws/aws-node-termination-handler)
This project ensures that the Kubernetes control plane responds appropriately to events that can cause your EC2 instance to become unavailable, such as EC2 maintenance events, EC2 Spot interruptions, ASG Scale-In, ASG AZ Rebalance, and EC2 Instance Termination via the API or Console. If not handled, your application code may not stop gracefully, take longer to recover full availability, or accidentally schedule work to nodes that are going down.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group_tag.aws_node_termination_handler_tag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag) | resource |
| [aws_autoscaling_lifecycle_hook.aws_node_termination_handler_hook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_cloudwatch_event_rule.aws_node_termination_handler_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.aws_node_termination_handler_rule_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.aws_node_termination_handler_irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_sqs_queue.aws_node_termination_handler_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.aws_node_termination_handler_queue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_iam_policy_document.aws_node_termination_handler_queue_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.irsa_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>  })</pre> | n/a | yes |
| <a name="input_autoscaling_group_names"></a> [autoscaling\_group\_names](#input\_autoscaling\_group\_names) | EKS Node Group ASG names | `list(string)` | n/a | yes |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | AWS Node Termination Handler Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_irsa_policies"></a> [irsa\_policies](#input\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | IAM role ARN for the service account |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | IAM role name for the service account |
| <a name="output_release_metadata"></a> [release\_metadata](#output\_release\_metadata) | Map of attributes of the Helm release metadata |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Name of Kubernetes service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
