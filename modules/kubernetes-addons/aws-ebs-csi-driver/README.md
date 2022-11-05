# aws-ebs-csi-driver

[aws-ebs-csi-driver](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html)
The EBS CSI driver provides a CSI interface used by container orchestrators to manage the lifecycle of Amazon EBS volumes. Availability in EKS add-ons in preview enables a simple experience for attaching persistent storage to an EKS cluster. The EBS CSI driver can now be installed, managed, and updated directly through the EKS console, CLI, and API

This addons supports managing AWS-EBS-CSI-DRIVER through either the EKS managed addon or a self-managed addon via Helm.

## EKS Managed AWS-EBS-CSI-DRIVER Addon

To enable and modify the EKS managed addon for aws-ebs-csi-driver, you can reference the following configuration and tailor to suit:

```hcl
  enable_amazon_eks_aws_ebs_csi_driver = true
  amazon_eks_aws_ebs_csi_driver_config = {
    resolve_conflicts = "OVERWRITE"
    ...
  }
```

## Self Managed AWS-EBS-CSI-DRIVER Addon

Official [aws-ebs-csi-driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) helm chart will be deploy in this mode

you must use this mode if you need to change the configuration of the ebs-csi-driver as this is not possible with the EKS managed mode

See the [`stateful`](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/stateful) example where the self-managed aws-ebs-csi-driver addon is used to provision the ebs-csi-driver on a EKS cluster

To provision the self managed addon for aws-ebs-csi-driver, you can reference the following configuration and tailor to suit:

 ```hcl
   enable_self_managed_aws_ebs_csi_driver = true
   self_managed_aws_ebs_csi_driver_helm_config = {
    ...
   }
  ```

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
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |
| <a name="module_irsa_addon"></a> [irsa\_addon](#module\_irsa\_addon) | ../../../modules/irsa | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_iam_policy.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_iam_policy_document.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_config"></a> [addon\_config](#input\_addon\_config) | Amazon EKS Managed Add-on config for EBS CSI Driver | `any` | `{}` | no |
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>  })</pre> | n/a | yes |
| <a name="input_enable_amazon_eks_aws_ebs_csi_driver"></a> [enable\_amazon\_eks\_aws\_ebs\_csi\_driver](#input\_enable\_amazon\_eks\_aws\_ebs\_csi\_driver) | Enable EKS Managed AWS EBS CSI Driver add-on | `bool` | `false` | no |
| <a name="input_enable_self_managed_aws_ebs_csi_driver"></a> [enable\_self\_managed\_aws\_ebs\_csi\_driver](#input\_enable\_self\_managed\_aws\_ebs\_csi\_driver) | Enable self-managed aws-ebs-csi-driver add-on | `bool` | `false` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Self-managed aws-ebs-csi-driver Helm chart config | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | IAM role ARN for the service account |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | IAM role name for the service account |
| <a name="output_release_metadata"></a> [release\_metadata](#output\_release\_metadata) | Map of attributes of the Helm release metadata |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Name of Kubernetes service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
