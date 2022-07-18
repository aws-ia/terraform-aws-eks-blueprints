# IRSA (IAM roles for Kubernetes Service Accounts)

This Terraform module creates the following resources

1.  Kubernetes Namespace for Kubernetes Addon
2.  Service Account for Kubernetes Addon
3.  IAM Role for Service Account with OIDC assume role policy
4.  Creates default policy required for Addon
5.  Attaches the additional IAM policies provided by consumer module

## Learn more

## Blogs

- [Introducing fine-grained IAM roles for service accounts](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/)
- [Cross account IAM roles for Kubernetes service accounts](https://aws.amazon.com/blogs/containers/cross-account-iam-roles-for-kubernetes-service-accounts/)
- [Enabling cross-account access to Amazon EKS cluster resources](https://aws.amazon.com/blogs/containers/enabling-cross-account-access-to-amazon-eks-cluster-resources/)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [kubernetes_namespace_v1.irsa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_service_account_v1.irsa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>    irsa_iam_role_name             = optional(string)<br>    irsa_iam_role_path             = optional(string)<br>    irsa_iam_permissions_boundary  = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_create_kubernetes_namespace"></a> [create\_kubernetes\_namespace](#input\_create\_kubernetes\_namespace) | Should the module create the namespace | `bool` | `true` | no |
| <a name="input_create_kubernetes_service_account"></a> [create\_kubernetes\_service\_account](#input\_create\_kubernetes\_service\_account) | Should the module create the Service Account | `bool` | `true` | no |
| <a name="input_irsa_iam_policies"></a> [irsa\_iam\_policies](#input\_irsa\_iam\_policies) | IAM Policies for IRSA IAM role | `list(string)` | `[]` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Kubernetes Namespace name | `string` | n/a | yes |
| <a name="input_kubernetes_service_account"></a> [kubernetes\_service\_account](#input\_kubernetes\_service\_account) | Kubernetes Service Account Name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_irsa_iam_role_arn"></a> [irsa\_iam\_role\_arn](#output\_irsa\_iam\_role\_arn) | IAM role ARN for your service account |
| <a name="output_irsa_iam_role_name"></a> [irsa\_iam\_role\_name](#output\_irsa\_iam\_role\_name) | IAM role name for your service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
