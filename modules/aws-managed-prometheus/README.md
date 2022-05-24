# AWS Managed Prometheus

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
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
