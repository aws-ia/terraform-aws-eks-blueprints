# Istio Helm Chart

## What is Tetrate Istio Distro
[TID](https://istio.tetratelabs.io/) is simple, safe enterprise-grade Istio distro.

<!--- BEGIN_TF_DOCS --->
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: MIT-0

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_base"></a> [base](#module\_base) | ./chart | n/a |
| <a name="module_cni"></a> [cni](#module\_cni) | ./chart | n/a |
| <a name="module_gateway"></a> [gateway](#module\_gateway) | ./chart | n/a |
| <a name="module_istiod"></a> [istiod](#module\_istiod) | ./chart | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_helm_config"></a> [base\_helm\_config](#input\_base\_helm\_config) | Istio `base` Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_cni_helm_config"></a> [cni\_helm\_config](#input\_cni\_helm\_config) | Istio `cni` Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_distribution"></a> [distribution](#input\_distribution) | Istio distribution | `string` | `"TID"` | no |
| <a name="input_distribution_version"></a> [distribution\_version](#input\_distribution\_version) | Istio version | `string` | `""` | no |
| <a name="input_gateway_helm_config"></a> [gateway\_helm\_config](#input\_gateway\_helm\_config) | Istio `gateway` Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_install_base"></a> [install\_base](#input\_install\_base) | Install Istio `base` Helm Chart | `bool` | `false` | no |
| <a name="input_install_cni"></a> [install\_cni](#input\_install\_cni) | Install Istio `cni` Helm Chart | `bool` | `false` | no |
| <a name="input_install_gateway"></a> [install\_gateway](#input\_install\_gateway) | Install Istio `gateway` Helm Chart | `bool` | `false` | no |
| <a name="input_install_istiod"></a> [install\_istiod](#input\_install\_istiod) | Install Istio `istiod` Helm Chart | `bool` | `false` | no |
| <a name="input_istiod_helm_config"></a> [istiod\_helm\_config](#input\_istiod\_helm\_config) | Istio `istiod` Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |

<!--- END_TF_DOCS --->
