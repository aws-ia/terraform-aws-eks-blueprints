# vpc-cni-metrics

[vpc-cni-metrics](https://docs.aws.amazon.com/eks/latest/userguide/cni-metrics-helper.html)
The Amazon VPC CNI plugin for Kubernetes metrics helper is a tool that you can use to scrape network interface and IP address information, aggregate metrics at the cluster level, and publish the metrics to Amazon CloudWatch.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.10 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc_cni_metrics_addon"></a> [vpc\_cni\_metrics\_addon](#module\_vpc\_cni\_metrics\_addon) | github.com/aws-ia/terraform-aws-eks-addon | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.aws_vpc_cni_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.aws_vpc_cni_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon. | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>    default_repository             = string<br>  })</pre> | n/a | yes |
| <a name="input_addon_version"></a> [addon\_version](#input\_addon\_version) | AWS VPC CNI Metrics image version | `string` | `"v1.12.1"` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for the aws\_load\_balancer\_controller. | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | IAM role ARN for the service account |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | IAM role name for the service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
