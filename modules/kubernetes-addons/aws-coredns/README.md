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

## Removing Default CoreDNS Deployment

Setting `remove_default_coredns_deployment = true` will remove the default CoreDNS deployment provided by EKS and update the labels and and annotations for kube-dns to allow Helm to manage it. These changes will allow for CoreDNS to be deployed via a Helm chart into a cluster either through self-managed addon (`enable_self_managed_coredns = true`) or some other means (i.e. - GitOps approach).

```hcl
  remove_default_coredns_deployment = true
```

# CoreDNS [Cluster Proportional Autoscaler](https://github.com/kubernetes-sigs/cluster-proportional-autoscaler)

By default, EKS provisions CoreDNS with a replica count of 2. As the cluster size increases and more traffic is flowing through the cluster, it is recommended to scale CoreDNS to meet this demand. The cluster proportional autoscaler is recommended to scale the CoreDNS deployment and therefore is provided by default when enabling CoreDNS through EKS Blueprints (either using EKS managed addon for CoreDNS, or self-managed addon for CoreDNS). A set of default settings for scaling CoreDNS is provided but users can provide their own settings as well to override the defaults via `cluster_proportional_autoscaler_helm_config = {}`. In addition, users have the ability to opt out of this default enablement and either not use the cluster proportional autoscaler for CoreDNS or provide a separate implementation of cluster proportional autoscaler.

```hcl
  enable_cluster_proportional_autoscaler      = true
  cluster_proportional_autoscaler_helm_config = { ... }
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.10 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.10 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.8 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster_proportional_autoscaler"></a> [cluster\_proportional\_autoscaler](#module\_cluster\_proportional\_autoscaler) | ../cluster-proportional-autoscaler | n/a |
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [null_resource.modify_kube_dns](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.remove_default_coredns_deployment](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_config"></a> [addon\_config](#input\_addon\_config) | Amazon EKS Managed CoreDNS Add-on config | `any` | `{}` | no |
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_cluster_proportional_autoscaler_helm_config"></a> [cluster\_proportional\_autoscaler\_helm\_config](#input\_cluster\_proportional\_autoscaler\_helm\_config) | Helm provider config for the CoreDNS cluster-proportional-autoscaler | `any` | `{}` | no |
| <a name="input_eks_cluster_certificate_authority_data"></a> [eks\_cluster\_certificate\_authority\_data](#input\_eks\_cluster\_certificate\_authority\_data) | The base64 encoded certificate data required to communicate with your cluster | `string` | `""` | no |
| <a name="input_enable_amazon_eks_coredns"></a> [enable\_amazon\_eks\_coredns](#input\_enable\_amazon\_eks\_coredns) | Enable Amazon EKS CoreDNS add-on | `bool` | `false` | no |
| <a name="input_enable_cluster_proportional_autoscaler"></a> [enable\_cluster\_proportional\_autoscaler](#input\_enable\_cluster\_proportional\_autoscaler) | Enable cluster-proportional-autoscaler | `bool` | `true` | no |
| <a name="input_enable_self_managed_coredns"></a> [enable\_self\_managed\_coredns](#input\_enable\_self\_managed\_coredns) | Enable self-managed CoreDNS add-on | `bool` | `false` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for the aws\_efs\_csi\_driver | `any` | `{}` | no |
| <a name="input_remove_default_coredns_deployment"></a> [remove\_default\_coredns\_deployment](#input\_remove\_default\_coredns\_deployment) | Determines whether the default deployment of CoreDNS is removed and ownership of kube-dns passed to Helm | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | IAM role ARN for the service account |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | IAM role name for the service account |
| <a name="output_release_metadata"></a> [release\_metadata](#output\_release\_metadata) | Map of attributes of the Helm release metadata |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Name of Kubernetes service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
