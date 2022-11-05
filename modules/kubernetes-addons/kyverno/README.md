# Kyverno

Kyverno is a policy engine that can help kubernetes clusters to enforce security and governance policies.

This addon provides support for:
1. [Kyverno](https://github.com/kyverno/kyverno/tree/main/charts/kyverno)
2. [Kyverno policies](https://github.com/kyverno/kyverno/tree/main/charts/kyverno-policies)
3. [Kyverno policy reporter](https://github.com/kyverno/policy-reporter/tree/main/charts/policy-reporter)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kyverno_helm_addon"></a> [kyverno\_helm\_addon](#module\_kyverno\_helm\_addon) | ../helm-addon | n/a |
| <a name="module_kyverno_policies_helm_addon"></a> [kyverno\_policies\_helm\_addon](#module\_kyverno\_policies\_helm\_addon) | ../helm-addon | n/a |
| <a name="module_kyverno_policy_reporter_helm_addon"></a> [kyverno\_policy\_reporter\_helm\_addon](#module\_kyverno\_policy\_reporter\_helm\_addon) | ../helm-addon | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_enable_kyverno_policies"></a> [enable\_kyverno\_policies](#input\_enable\_kyverno\_policies) | Enable Kyverno policies | `bool` | `false` | no |
| <a name="input_enable_kyverno_policy_reporter"></a> [enable\_kyverno\_policy\_reporter](#input\_enable\_kyverno\_policy\_reporter) | Enable Kyverno UI | `bool` | `false` | no |
| <a name="input_kyverno_helm_config"></a> [kyverno\_helm\_config](#input\_kyverno\_helm\_config) | Helm provider config for the Kyverno | `any` | `{}` | no |
| <a name="input_kyverno_policies_helm_config"></a> [kyverno\_policies\_helm\_config](#input\_kyverno\_policies\_helm\_config) | Helm provider config for the Kyverno baseline policies | `any` | `{}` | no |
| <a name="input_kyverno_policy_reporter_helm_config"></a> [kyverno\_policy\_reporter\_helm\_config](#input\_kyverno\_policy\_reporter\_helm\_config) | Helm provider config for the Kyverno policy reporter UI | `any` | `{}` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | IAM role ARN for the service account |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | IAM role name for the service account |
| <a name="output_release_metadata"></a> [release\_metadata](#output\_release\_metadata) | Map of attributes of the Helm release metadata |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Name of Kubernetes service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
