# AWS Managed Prometheus



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

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_prometheus_workspace.amp_workspace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amazon_prometheus_workspace_alias"></a> [amazon\_prometheus\_workspace\_alias](#input\_amazon\_prometheus\_workspace\_alias) | AWS Managed Prometheus WorkSpace Name | `string` | `null` | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amazon_prometheus_workspace_arn"></a> [amazon\_prometheus\_workspace\_arn](#output\_amazon\_prometheus\_workspace\_arn) | Amazon Managed Prometheus Workspace ARN |
| <a name="output_amazon_prometheus_workspace_endpoint"></a> [amazon\_prometheus\_workspace\_endpoint](#output\_amazon\_prometheus\_workspace\_endpoint) | Amazon Managed Prometheus Workspace Endpoint |
| <a name="output_amazon_prometheus_workspace_id"></a> [amazon\_prometheus\_workspace\_id](#output\_amazon\_prometheus\_workspace\_id) | Amazon Managed Prometheus Workspace ID |

<!--- END_TF_DOCS --->
