# Helm AddOn

## Introduction

Helm Addon module can be used to provision a generic Helm Chart as an Add-On for an EKS cluster provisioned using the SSP. This module does the following:

1. Create an IAM role for Service Accounts with the provided configuration for the [`irsa`](./../../irsa) module.
2. If `manage_via_gitops` is set to `false`, provision the helm chart for the add-on based on the configuration provided for the `helm_config` as defined in the [helm provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) documentation.

<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa"></a> [irsa](#module\_irsa) | ../../irsa | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.addon](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Add-on helm chart config, provide repository and version at the minimum.<br>See https://registry.terraform.io/providers/hashicorp/helm/latest/docs. | `any` | n/a | yes |
| <a name="input_irsa_config"></a> [irsa\_config](#input\_irsa\_config) | Input configuration for IRSA module | <pre>object({<br>    kubernetes_namespace              = string<br>    create_kubernetes_namespace       = bool<br>    kubernetes_service_account        = string<br>    create_kubernetes_service_account = bool<br>    eks_cluster_id                    = string<br>    iam_role_path                     = string<br>    tags                              = map(string)<br>    irsa_iam_policies                 = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |
| <a name="input_set_sensitive_values"></a> [set\_sensitive\_values](#input\_set\_sensitive\_values) | Forced set\_sensitive values | `any` | `[]` | no |
| <a name="input_set_values"></a> [set\_values](#input\_set\_values) | Forced set values | `any` | `[]` | no |

## Outputs

No outputs.

<!--- END_TF_DOCS --->
