# Agones Helm Chart

## Agones
Agones is an Open source Kubernetes Controller with custom resource definitions and is used to create, run, manage and scale dedicated game server processes within Kubernetes clusters using standard Kubernetes tooling and APIs. This model also allows any matchmaker to interact directly with Agones via the Kubernetes API to provision a dedicated game server

## GameLift
Amazon GameLift enables developers to deploy, operate, and scale dedicated, low-cost servers in the cloud for session-based, multiplayer games. Built on AWS global computing infrastructure, GameLift helps deliver high-performance, high-reliability, low-cost game servers while dynamically scaling your resource usage to meet worldwide player demand.

     https://github.com/googleforgames/agones/tree/main/install/helm/agones
     https://artifacthub.io/packages/helm/agones/agones

DOCKER IMAGES

      gcr.io/agones-images/agones-controller:1.15.0-rc
      gcr.io/agones-images/agones-ping:1.15.0-rc
      gcr.io/agones-images/agones-allocator:1.15.0-rc



<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_security_group_rule.agones_sg_ingress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [aws_security_group.eks_worker_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_eks_worker_security_group_id"></a> [eks\_worker\_security\_group\_id](#input\_eks\_worker\_security\_group\_id) | EKS Worker Security Group ID | `string` | n/a | yes |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for Agones GameServer | `any` | `{}` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |

<!--- END_TF_DOCS --->
