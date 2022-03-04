# Spark on K8s Operator
The Kubernetes Operator for Apache Spark aims to make specifying and running Spark applications as easy and idiomatic as running other workloads on Kubernetes.
It uses Kubernetes custom resources for specifying, running, and surfacing status of Spark applications.


#### AWS Service annotations for Nginx Ingress Controller

<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |
| <a name="module_spark-irsa"></a> [spark-irsa](#module\_spark-irsa) | ../../irsa | n/a |
| <a name="module_spark-operator-irsa"></a> [spark-operator-irsa](#module\_spark-operator-irsa) | ../../irsa | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for Spark K8s Operator | `any` | `{}` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps | `bool` | `false` | no |
| <a name="input_spark_irsa_permissions_boundary"></a> [spark\_irsa\_permissions\_boundary](#input\_spark\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary for Spark App | `string` | `""` | no |
| <a name="input_spark_irsa_policies"></a> [spark\_irsa\_policies](#input\_spark\_irsa\_policies) | IAM Policy ARN list for any IRSA policies for Spark App | `list(string)` | `[]` | no |
| <a name="input_spark_operator_irsa_permissions_boundary"></a> [spark\_operator\_irsa\_permissions\_boundary](#input\_spark\_operator\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary Spark Operator | `string` | `""` | no |
| <a name="input_spark_operator_irsa_policies"></a> [spark\_operator\_irsa\_policies](#input\_spark\_operator\_irsa\_policies) | IAM Policy ARN list for any IRSA policies for Spark Operator | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |

<!--- END_TF_DOCS --->
