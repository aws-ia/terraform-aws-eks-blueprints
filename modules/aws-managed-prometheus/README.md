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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa"></a> [irsa](#module\_irsa) | ../irsa | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ingest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.query](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_prometheus_workspace.amp_workspace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ingest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.query](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amazon_prometheus_workspace_alias"></a> [amazon\_prometheus\_workspace\_alias](#input\_amazon\_prometheus\_workspace\_alias) | AWS Managed Prometheus WorkSpace Name | `string` | `null` | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster ID | `string` | n/a | yes |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `"/"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Prometheus Server Namespace | `string` | `"prometheus"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amazon_prometheus_ingest_iam_role_arn"></a> [amazon\_prometheus\_ingest\_iam\_role\_arn](#output\_amazon\_prometheus\_ingest\_iam\_role\_arn) | Amazon Managed Prometheus Ingest IAM Role ARN |
| <a name="output_amazon_prometheus_ingest_service_account"></a> [amazon\_prometheus\_ingest\_service\_account](#output\_amazon\_prometheus\_ingest\_service\_account) | n/a |
| <a name="output_amazon_prometheus_query_iam_role_arn"></a> [amazon\_prometheus\_query\_iam\_role\_arn](#output\_amazon\_prometheus\_query\_iam\_role\_arn) | Amazon Managed Prometheus Query IAM Role ARN |
| <a name="output_amazon_prometheus_query_service_account"></a> [amazon\_prometheus\_query\_service\_account](#output\_amazon\_prometheus\_query\_service\_account) | n/a |
| <a name="output_amazon_prometheus_workspace_id"></a> [amazon\_prometheus\_workspace\_id](#output\_amazon\_prometheus\_workspace\_id) | Amazon Managed Prometheus Workspace ID |

<!--- END_TF_DOCS --->
