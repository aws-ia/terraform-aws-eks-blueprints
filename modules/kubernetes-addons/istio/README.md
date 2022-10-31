<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_istio-base"></a> [istio-base](#module\_istio-base) | ../helm-addon | n/a |
| <a name="module_istio-cni"></a> [istio-cni](#module\_istio-cni) | ../helm-addon | n/a |
| <a name="module_istio-ingressgateway"></a> [istio-ingressgateway](#module\_istio-ingressgateway) | ../helm-addon | n/a |
| <a name="module_istiod"></a> [istiod](#module\_istiod) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace.istio_system](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_cleanup_on_fail"></a> [cleanup\_on\_fail](#input\_cleanup\_on\_fail) | Allow deletion of new resources created in this upgrade when upgrade fails | `bool` | `true` | no |
| <a name="input_force_update"></a> [force\_update](#input\_force\_update) | Force resource update through delete/recreate if needed | `bool` | `false` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm Config for Istio | `any` | `{}` | no |
| <a name="input_install_istio-base"></a> [install\_istio-base](#input\_install\_istio-base) | Install Istio `base` Helm Chart | `bool` | `true` | no |
| <a name="input_install_istio-cni"></a> [install\_istio-cni](#input\_install\_istio-cni) | Install Istio `cni` Helm Chart | `bool` | `true` | no |
| <a name="input_install_istio-ingressgateway"></a> [install\_istio-ingressgateway](#input\_install\_istio-ingressgateway) | Install Istio `gateway` Helm Chart | `bool` | `true` | no |
| <a name="input_install_istiod"></a> [install\_istiod](#input\_install\_istiod) | Install Istio `istiod` Helm Chart | `bool` | `true` | no |
| <a name="input_istio_base_settings"></a> [istio\_base\_settings](#input\_istio\_base\_settings) | Additional settings which will be passed to the Helm chart values | `map(any)` | `{}` | no |
| <a name="input_istio_gateway_settings"></a> [istio\_gateway\_settings](#input\_istio\_gateway\_settings) | Additional settings which will be passed to the Helm chart values | `map(any)` | `{}` | no |
| <a name="input_istio_version"></a> [istio\_version](#input\_istio\_version) | Version of the Helm chart | `string` | `"1.15.2"` | no |
| <a name="input_istiod_global_meshID"></a> [istiod\_global\_meshID](#input\_istiod\_global\_meshID) | Istio telementry mesh name | `string` | `"mesh1"` | no |
| <a name="input_istiod_global_network"></a> [istiod\_global\_network](#input\_istiod\_global\_network) | Istio telementry network name | `string` | `"network1"` | no |
| <a name="input_istiod_meshConfig_accessLogFile"></a> [istiod\_meshConfig\_accessLogFile](#input\_istiod\_meshConfig\_accessLogFile) | The mesh config access log file | `string` | `"/dev/stdout"` | no |
| <a name="input_istiod_meshConfig_enableAutoMtls"></a> [istiod\_meshConfig\_enableAutoMtls](#input\_istiod\_meshConfig\_enableAutoMtls) | The mesh config enable AutoMtls | `bool` | `"true"` | no |
| <a name="input_istiod_meshConfig_rootNamespace"></a> [istiod\_meshConfig\_rootNamespace](#input\_istiod\_meshConfig\_rootNamespace) | The mesh config root namespace | `string` | `"istio-system"` | no |
| <a name="input_istiod_meshConfig_trustDomain"></a> [istiod\_meshConfig\_trustDomain](#input\_istiod\_meshConfig\_trustDomain) | The trust domain corresponds to the trust root of a system | `string` | `"td1"` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
<!-- END_TF_DOCS -->