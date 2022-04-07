# AWS OpenTelemetry Operator

[AWS Distro for OpenTelemetry (ADOT)](https://aws-otel.github.io/) is a secure,
production-ready, AWS-supported distribution of the OpenTelemetry project.
Part of the Cloud Native Computing Foundation, OpenTelemetry provides open
source APIs, libraries, and agents to collect distributed traces and metrics
for application monitoring.

This modules deploys the ADOT OpenTelemetry Operator through helm.
The OpenTelemetry Operator is an implementation of a Kubernetes Operator.
A Kubernetes Operator is a method of packaging, deploying and managing a
Kubernetes-native application, which is both deployed on Kubernetes and
managed using the Kubernetes APIs and kubectl tooling. The Kubernetes Operator
is a custom controller, which introduces new object types through Custom Resource
Definition (CRD), an extension mechanism in Kubernetes.
In this case, the CRD that is managed by the OpenTelemetry Operator is the Collector.

<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_certificate"></a> [certificate](#module\_certificate) | ../cert-manager | n/a |
| <a name="module_operator"></a> [operator](#module\_operator) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace_v1.prometheus](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    irsa_iam_permissions_boundary  = string<br>    irsa_iam_role_path             = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
<!--- END_TF_DOCS --->
