# Helm AddOn

## What is Helm AddOn

yada yada

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
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Add-on helm chart config, provide repository and version at the minimum | `any` | n/a | yes |
| <a name="input_irsa_config"></a> [irsa\_config](#input\_irsa\_config) | Input configuration for IRSA | <pre>object({<br>    kubernetes_namespace              = string<br>    create_kubernetes_namespace       = bool<br>    kubernetes_service_account        = string<br>    create_kubernetes_service_account = bool<br>    eks_cluster_id                    = string<br>    iam_role_path                     = string<br>    tags                              = string<br>    irsa_iam_policies                 = list(string)<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!--- END_TF_DOCS --->
