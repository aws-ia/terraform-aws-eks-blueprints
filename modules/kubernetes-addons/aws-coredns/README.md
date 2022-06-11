# [CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)

This addons supports managing CoreDNS through either the EKS managed addon or a self-managed addon via Helm.

## EKS Managed CoreDNS Addon

To enable and modify the EKS managed addon for CoreDNS, you can reference the following configuration and tailor to suit:

```hcl
  enable_amazon_eks_coredns = true
  amazon_eks_coredns_config = {
    most_recent        = true
    kubernetes_version = "1.21"
    resolve_conflicts  = "OVERWRITE"
    ...
  }
```

## Self Managed CoreDNS Addon

⚠️ Note: The EKS service by default provides and manages a CoreDNS deployment on clusters created after 1.18. In order to utilize the self-managed addon without conflicting with the EKS API that by default manages the addon, users will need to update the existing CoreDNS resources. Those changes that are required before deploying the addon are listed below. This change will result in downtime due to the deletion of the existing CoreDNS deployment.

```sh
kubectl --namespace kube-system delete deployment coredns
kubectl --namespace kube-system annotate --overwrite service kube-dns meta.helm.sh/release-name=coredns
kubectl --namespace kube-system annotate --overwrite service kube-dns meta.helm.sh/release-namespace=kube-system
kubectl --namespace kube-system label --overwrite service kube-dns app.kubernetes.io/managed-by=Helm
```

See the [`fargate-serverless`](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/fargate-serverless) example where the self-managed CoreDNS addon is used to provision CoreDNS on a serverless cluster (data plane).

To provision the self managed addon for CoreDNS, you can reference the following configuration and tailor to suit:

```hcl
  enable_self_managed_coredns = true
  self_managed_coredns_helm_config = {
    compute_type       = "fargate"
    kubernetes_version = "1.22"
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

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_config"></a> [addon\_config](#input\_addon\_config) | Amazon EKS Managed CoreDNS Add-on config | `any` | `{}` | no |
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_enable_amazon_eks_coredns"></a> [enable\_amazon\_eks\_coredns](#input\_enable\_amazon\_eks\_coredns) | Enable Amazon EKS CoreDNS add-on | `bool` | `false` | no |
| <a name="input_enable_self_managed_coredns"></a> [enable\_self\_managed\_coredns](#input\_enable\_self\_managed\_coredns) | Enable self-managed CoreDNS add-on | `bool` | `false` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for the aws\_efs\_csi\_driver | `any` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
