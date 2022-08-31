
# Kyverno

Kyverno is a policy engine that can help kubernetes clusters to enforce security and governance policies
For more details checkout [kyverno](https://kyverno.io/)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kyverno_helm_addon"></a> [kyverno\_helm\_addon](#module\_kyverno\_helm\_addon) | ../helm-addon | n/a |
| <a name="module_kyverno_policies_helm_addon"></a> [kyverno\_policies\_helm\_addon](#module\_kyverno\_policies\_helm\_addon) | ../helm-addon | n/a |
| <a name="module_kyverno_ui_helm_addon"></a> [kyverno\_ui\_helm\_addon](#module\_kyverno\_ui\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_kyverno_helm_config"></a> [kyverno\_helm\_config](#input\_kyverno\_helm\_config) | Helm provider config for the Kyverno | `any` | `{}` | no |
| <a name="input_kyverno_policies_helm_config"></a> [kyverno\_policies\_helm\_config](#input\_kyverno\_policies\_helm\_config) | Helm provider config for the Kyverno baseline policies | `any` | `{}` | no |
| <a name="input_kyverno_ui_helm_config"></a> [kyverno\_ui\_helm\_config](#input\_kyverno\_ui\_helm\_config) | Helm provider config for the Kyverno policy reporter UI | `any` | `{}` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
