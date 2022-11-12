# Prometheus Helm Chart

## Instructions to upload Prometheus Docker image to AWS ECR

Step 1: Get the latest docker image from this link

        https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml

Step 2: Download the docker image to your local Mac/Laptop

        $ docker pull quay.io/prometheus/prometheus:v2.31.1
        $ docker pull quay.io/prometheus/alertmanager:v0.23.0
        $ docker pull jimmidyson/configmap-reload:v0.5.0
        $ docker pull quay.io/prometheus/node-exporter:v1.3.0
        $ docker pull prom/pushgateway:v1.4.2

Step 3: Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:

        $ aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account id>.dkr.ecr.eu-west-1.amazonaws.com

Step 4: Create an ECR repo for each image mentioned in Step 2 with the same in ECR. See example for

        $ aws ecr create-repository \
              --repository-name quay.io/prometheus/prometheus \
              --image-scanning-configuration scanOnPush=true

Repeat the above steps for other 4 images

Step 5: After the build completes, tag your image so, you can push the image to this repository:

        $ docker tag quay.io/prometheus/prometheus:v2.31.1 <accountid>.dkr.ecr.eu-west-1.amazonaws.com/quay.io/prometheus/prometheus:v2.31.1

Repeat the above steps for other 4 images

Step 6: Run the following command to push this image to your newly created AWS repository:

        $ docker push <accountid>.dkr.ecr.eu-west-1.amazonaws.com/quay.io/prometheus/prometheus:v2.31.1

Repeat the above steps for other 4 images

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |
| <a name="module_irsa_amp_ingest"></a> [irsa\_amp\_ingest](#module\_irsa\_amp\_ingest) | ../../../modules/irsa | n/a |
| <a name="module_irsa_amp_query"></a> [irsa\_amp\_query](#module\_irsa\_amp\_query) | ../../../modules/irsa | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ingest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.query](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [kubernetes_namespace_v1.prometheus](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [aws_iam_policy_document.ingest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.query](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>  })</pre> | n/a | yes |
| <a name="input_amazon_prometheus_workspace_endpoint"></a> [amazon\_prometheus\_workspace\_endpoint](#input\_amazon\_prometheus\_workspace\_endpoint) | Amazon Managed Prometheus Workspace Endpoint | `string` | `null` | no |
| <a name="input_enable_amazon_prometheus"></a> [enable\_amazon\_prometheus](#input\_enable\_amazon\_prometheus) | Enable AWS Managed Prometheus service | `bool` | `false` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm Config for Prometheus | `any` | `{}` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | IAM role ARN for the service account |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | IAM role name for the service account |
| <a name="output_release_metadata"></a> [release\_metadata](#output\_release\_metadata) | Map of attributes of the Helm release metadata |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Name of Kubernetes service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
