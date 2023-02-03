# Cert Manager Deployment Guide

## Introduction

Cert Manager adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates.

## Helm Chart

### Instructions to use the Helm Chart

See the [cert-manager documentation](https://cert-manager.io/docs/installation/helm/).

# Docker Image for Cert Manager

cert-manager docker image is available at this repo:

<https://quay.io/repository/jetstack/cert-manager-controller?tag=latest&tab=tags>

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.10 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.10 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.4.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.cert_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [helm_release.cert_manager_ca](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert_manager_letsencrypt](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_iam_policy_document.cert_manager_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>  })</pre> | n/a | yes |
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | Domain names of the Route53 hosted zone to use with cert-manager. | `list(string)` | `[]` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | cert-manager Helm chart configuration | `any` | `{}` | no |
| <a name="input_install_letsencrypt_issuers"></a> [install\_letsencrypt\_issuers](#input\_install\_letsencrypt\_issuers) | Install Let's Encrypt Cluster Issuers. | `bool` | `true` | no |
| <a name="input_irsa_policies"></a> [irsa\_policies](#input\_irsa\_policies) | Additional IAM policies used for the add-on service account. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_svc_image_pull_secrets"></a> [kubernetes\_svc\_image\_pull\_secrets](#input\_kubernetes\_svc\_image\_pull\_secrets) | list(string) of kubernetes imagePullSecrets | `list(string)` | `[]` | no |
| <a name="input_letsencrypt_email"></a> [letsencrypt\_email](#input\_letsencrypt\_email) | Email address for expiration emails from Let's Encrypt. | `string` | `""` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | Current AWS EKS Cluster ID |
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | IAM role ARN for the service account |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | IAM role name for the service account |
| <a name="output_release_metadata"></a> [release\_metadata](#output\_release\_metadata) | Map of attributes of the Helm release metadata |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Name of Kubernetes service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
