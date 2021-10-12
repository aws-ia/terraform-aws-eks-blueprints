# Cert Manager Deployment Guide

# Introduction

Cert Manager adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates.

# Helm Chart

### Instructions to use the Helm Chart

See the [cert-manager documentation](https://cert-manager.io/docs/installation/helm/).


# Docker Image for Cert Manager

cert-manager docker image is available at this repo:

https://quay.io/repository/jetstack/cert-manager-controller?tag=latest&tab=tags


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert_manager_ca](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cert_manager_helm_chart_name"></a> [cert\_manager\_helm\_chart\_name](#input\_cert\_manager\_helm\_chart\_name) | n/a | `string` | `"cert-manager"` | no |
| <a name="input_cert_manager_helm_chart_url"></a> [cert\_manager\_helm\_chart\_url](#input\_cert\_manager\_helm\_chart\_url) | n/a | `string` | `"https://charts.jetstack.io"` | no |
| <a name="input_cert_manager_helm_chart_version"></a> [cert\_manager\_helm\_chart\_version](#input\_cert\_manager\_helm\_chart\_version) | Helm chart version for cert-manager | `string` | `"v1.5.3"` | no |
| <a name="input_cert_manager_image_repo_name"></a> [cert\_manager\_image\_repo\_name](#input\_cert\_manager\_image\_repo\_name) | n/a | `string` | `"quay.io/jetstack/cert-manager-controller"` | no |
| <a name="input_cert_manager_image_tag"></a> [cert\_manager\_image\_tag](#input\_cert\_manager\_image\_tag) | Docker image tag for cert-manager controller | `string` | `"v1.5.3"` | no |
| <a name="input_cert_manager_install_crds"></a> [cert\_manager\_install\_crds](#input\_cert\_manager\_install\_crds) | Whether Cert Manager CRDs should be installed as part of the cert-manager Helm chart installation | `bool` | `true` | no |
| <a name="input_private_container_repo_url"></a> [private\_container\_repo\_url](#input\_private\_container\_repo\_url) | n/a | `string` | n/a | yes |
| <a name="input_public_docker_repo"></a> [public\_docker\_repo](#input\_public\_docker\_repo) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
