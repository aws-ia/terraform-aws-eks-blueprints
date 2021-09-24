## Pre-requisites

[cert-manager](https://cert-manager.io/) is currently needed to enable Windows support. The `cert-manager` [Helm chart](../cert-manager) will be automatically enabeld, if Windows support is enabled.

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
| [helm_release.windows_vpc_controllers](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admission_webhook_image_repo_name"></a> [admission\_webhook\_image\_repo\_name](#input\_admission\_webhook\_image\_repo\_name) | n/a | `string` | `"eks/vpc-admission-webhook"` | no |
| <a name="input_admission_webhook_image_tag"></a> [admission\_webhook\_image\_tag](#input\_admission\_webhook\_image\_tag) | Docker image tag for Windows VPC admission webhook controller | `string` | `"v0.2.7"` | no |
| <a name="input_private_container_repo_url"></a> [private\_container\_repo\_url](#input\_private\_container\_repo\_url) | n/a | `any` | n/a | yes |
| <a name="input_public_docker_repo"></a> [public\_docker\_repo](#input\_public\_docker\_repo) | n/a | `any` | n/a | yes |
| <a name="input_public_image_repo"></a> [public\_image\_repo](#input\_public\_image\_repo) | n/a | `string` | `"602401143452.dkr.ecr.us-west-2.amazonaws.com"` | no |
| <a name="input_resource_controller_image_repo_name"></a> [resource\_controller\_image\_repo\_name](#input\_resource\_controller\_image\_repo\_name) | n/a | `string` | `"eks/windows-vpc-resource-controller"` | no |
| <a name="input_resource_controller_image_tag"></a> [resource\_controller\_image\_tag](#input\_resource\_controller\_image\_tag) | Docker image tag for Windows VPC resource controller | `string` | `"v0.2.7"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->