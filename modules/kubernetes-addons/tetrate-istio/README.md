# Tetrate Istio add-on

## What is Tetrate Istio Distro

[Tetrate Istio Distro](https://istio.tetratelabs.io/) is simple, safe enterprise-grade Istio distro.

## Examples

See [blueprints](https://github.com/tetratelabs/terraform-eksblueprints-tetrate-istio-addon/tree/main/blueprints).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_base"></a> [base](#module\_base) | ../helm-addon | n/a |
| <a name="module_cni"></a> [cni](#module\_cni) | ../helm-addon | n/a |
| <a name="module_gateway"></a> [gateway](#module\_gateway) | ../helm-addon | n/a |
| <a name="module_istiod"></a> [istiod](#module\_istiod) | ../helm-addon | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | `any` | n/a | yes |
| <a name="input_base_helm_config"></a> [base\_helm\_config](#input\_base\_helm\_config) | Istio `base` Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_cni_helm_config"></a> [cni\_helm\_config](#input\_cni\_helm\_config) | Istio `cni` Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_distribution"></a> [distribution](#input\_distribution) | Istio distribution | `string` | `"TID"` | no |
| <a name="input_distribution_version"></a> [distribution\_version](#input\_distribution\_version) | Istio version | `string` | `""` | no |
| <a name="input_gateway_helm_config"></a> [gateway\_helm\_config](#input\_gateway\_helm\_config) | Istio `gateway` Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_install_base"></a> [install\_base](#input\_install\_base) | Install Istio `base` Helm Chart | `bool` | `true` | no |
| <a name="input_install_cni"></a> [install\_cni](#input\_install\_cni) | Install Istio `cni` Helm Chart | `bool` | `true` | no |
| <a name="input_install_gateway"></a> [install\_gateway](#input\_install\_gateway) | Install Istio `gateway` Helm Chart | `bool` | `true` | no |
| <a name="input_install_istiod"></a> [install\_istiod](#input\_install\_istiod) | Install Istio `istiod` Helm Chart | `bool` | `true` | no |
| <a name="input_istiod_helm_config"></a> [istiod\_helm\_config](#input\_istiod\_helm\_config) | Istio `istiod` Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
