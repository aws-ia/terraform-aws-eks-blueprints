# Crossplane

Crossplane is an open source Kubernetes add-on that enables platform teams to assemble infrastructure from multiple vendors, and expose higher level self-service APIs for application teams to consume, without having to write any code.

- Crossplane is a control plane
- Allow engineers to model their infrastructure as declarative configuration
- Support managing a myriad of diverse infrastructure using "provider" plugins
- It's an open source tool with strong communities

Please find more details from [Crossplane](https://crossplane.io/)

## Usage

Crossplane Add-on can be deployed as follows

```hcl
  enable_crossplane = true
```

This module allows you to deploy the following AWS providers for Crossplane. These providers disabled by default.

- [AWS Provider](https://github.com/crossplane/provider-aws)
- [Provider Jet AWS](https://github.com/crossplane-contrib/provider-jet-aws)

Refer to [docs](../../../docs/add-ons/crossplane.md) on how to deploy AWS Providers.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.14 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_provider_irsa"></a> [aws\_provider\_irsa](#module\_aws\_provider\_irsa) | ../../../modules/irsa | n/a |
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |
| <a name="module_jet_aws_provider_irsa"></a> [jet\_aws\_provider\_irsa](#module\_jet\_aws\_provider\_irsa) | ../../../modules/irsa | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.jet_aws_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [kubectl_manifest.aws_controller_config](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.aws_provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.aws_provider_config](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.jet_aws_controller_config](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.jet_aws_provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.jet_aws_provider_config](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.kubernetes_controller_clusterolebinding](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.kubernetes_controller_config](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.kubernetes_provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.kubernetes_provider_config](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace_v1.crossplane](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_service_account_v1.kubernetes_controller](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [time_sleep.wait_30_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_30_seconds_kubernetes](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_policy_document.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>  })</pre> | n/a | yes |
| <a name="input_aws_provider"></a> [aws\_provider](#input\_aws\_provider) | AWS Provider config for Crossplane | `any` | n/a | yes |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for the Argo Rollouts | `any` | `{}` | no |
| <a name="input_jet_aws_provider"></a> [jet\_aws\_provider](#input\_jet\_aws\_provider) | AWS Provider Jet AWS config for Crossplane | <pre>object({<br>    enable                   = bool<br>    provider_aws_version     = string<br>    additional_irsa_policies = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_kubernetes_provider"></a> [kubernetes\_provider](#input\_kubernetes\_provider) | Kubernetes Provider config for Crossplane | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | IAM role ARN for the service account |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | IAM role name for the service account |
| <a name="output_release_metadata"></a> [release\_metadata](#output\_release\_metadata) | Map of attributes of the Helm release metadata |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Name of Kubernetes service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
