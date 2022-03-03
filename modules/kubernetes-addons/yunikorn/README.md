# YuniKorn Helm Chart

## What is YuniKorn
[YuniKorn](https://yunikorn.apache.org/) Resource Scheduler for K8s. Fully K8s compatible, an alternative of the default K8s scheduler, but more powerful. Transparent for the existing K8s applications.

[Apache YuniKorn (Incubating)](https://yunikorn.apache.org/) is a new Apache incubator project that offers rich scheduling capabilities on Kubernetes. It fills the scheduling gap while running Big Data workloads on Kubernetes, with a ton of useful features such as hierarchical queues, elastic queue quotas, resource fairness, and job ordering.

Helm Chart Repo  https://github.com/apache/incubator-yunikorn-release/tree/master/helm-charts


<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for Yunikorn | `any` | `{}` | no |
| <a name="input_irsa_permissions_boundary"></a> [irsa\_permissions\_boundary](#input\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary | `string` | `""` | no |
| <a name="input_irsa_policies"></a> [irsa\_policies](#input\_irsa\_policies) | IAM Policy ARN list for any IRSA policies | `list(string)` | `[]` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |

<!--- END_TF_DOCS --->
