# aws-opentelemetry-eks

<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.eks_aws_otel_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.managed_node_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.self_managed_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [kubernetes_deployment.aws_otel_eks_sidecar](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_namespace.aws_otel_eks](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_open_telemetry_addon"></a> [aws\_open\_telemetry\_addon](#input\_aws\_open\_telemetry\_addon) | AWS Open Telemetry Distro Addon Configuration | `any` | `{}` | no |
| <a name="input_aws_open_telemetry_mg_node_iam_role_arns"></a> [aws\_open\_telemetry\_mg\_node\_iam\_role\_arns](#input\_aws\_open\_telemetry\_mg\_node\_iam\_role\_arns) | n/a | `list(string)` | `[]` | no |
| <a name="input_aws_open_telemetry_self_mg_node_iam_role_arns"></a> [aws\_open\_telemetry\_self\_mg\_node\_iam\_role\_arns](#input\_aws\_open\_telemetry\_self\_mg\_node\_iam\_role\_arns) | n/a | `list(string)` | `[]` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |

<!--- END_TF_DOCS --->
