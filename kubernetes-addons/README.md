## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-for-fluent-bit"></a> [aws-for-fluent-bit](#module\_aws-for-fluent-bit) | ./aws-for-fluent-bit |  |
| <a name="module_cluster_autoscaler"></a> [cluster\_autoscaler](#module\_cluster\_autoscaler) | ./cluster_autoscaler |  |
| <a name="module_metrics_server"></a> [metrics\_server](#module\_metrics\_server) | ./metrics_server |  |
| <a name="module_traefik_ingress"></a> [traefik\_ingress](#module\_traefik\_ingress) | ./traefik_ingress |  |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_for_fluent_bit_enable"></a> [aws\_for\_fluent\_bit\_enable](#input\_aws\_for\_fluent\_bit\_enable) | Enabling aws\_fluent\_bit on eks cluster | `bool` | `false` | no |
| <a name="input_cluster_autoscaler_enable"></a> [cluster\_autoscaler\_enable](#input\_cluster\_autoscaler\_enable) | Enabling cluster autoscaler server on eks cluster | `bool` | `true` | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS cluster Id | `any` | n/a | yes |
| <a name="input_ekslog_retention_in_days"></a> [ekslog\_retention\_in\_days](#input\_ekslog\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days. | `any` | n/a | yes |
| <a name="input_private_container_repo_url"></a> [image\_repo\_url](#input\_image\_repo\_url) | n/a | `any` | n/a | yes |
| <a name="input_metrics_server_enable"></a> [metrics\_server\_enable](#input\_metrics\_server\_enable) | Enabling metrics server on eks cluster | `bool` | `true` | no |
| <a name="input_s3_nlb_logs"></a> [s3\_nlb\_logs](#input\_s3\_nlb\_logs) | S3 bucket for NLB Logs | `any` | n/a | yes |
| <a name="input_traefik_ingress_controller_enable"></a> [traefik\_enable](#input\_traefik\_enable) | Enabling Traefik Ingress on eks cluster | `bool` | `false` | no |

## Outputs

No outputs.
