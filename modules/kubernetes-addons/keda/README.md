# KEDA Helm Chart

## What is Keda

[KEDA](https://keda.sh/) is a Kubernetes-based Event Driven Autoscaler. With KEDA, you can drive the scaling of any container in Kubernetes based on the number of events needing to be processed.

KEDA is a single-purpose and lightweight component that can be added into any Kubernetes cluster. KEDA works alongside standard Kubernetes components like the [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) and can extend functionality without overwriting or duplication. With KEDA you can explicitly map the apps you want to use event-driven scale, with other apps continuing to function. This makes KEDA a flexible and safe option to run alongside any number of any other Kubernetes applications or frameworks

## WARNING

Sometimes kubernetes namespace `keda-ns` created by this helm chart failed to delete due to the [defect](https://github.com/kedacore/keda/issues/1231)

Workaround is to run the following command manually to clean up the namespace and rerun the `terraform apply`

```sh
kubectl delete apiservice v1beta1.external.metrics.k8s.io
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.keda_irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.keda_irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>  })</pre> | n/a | yes |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for the KEDA | `any` | `{}` | no |
| <a name="input_irsa_policies"></a> [irsa\_policies](#input\_irsa\_policies) | IAM Policy ARN list for any IRSA policies | `list(string)` | `[]` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | IAM role ARN for the service account |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | IAM role name for the service account |
| <a name="output_release_metadata"></a> [release\_metadata](#output\_release\_metadata) | Map of attributes of the Helm release metadata |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Name of Kubernetes service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
