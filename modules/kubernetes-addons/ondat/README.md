# Ondat add-on for EKS Blueprints

## Introduction

[Ondat](https://ondat.io) is a highly scalable Kubernetes data plane that
provides stateful storage for applications. This blueprint installs Ondat
on Amazon Elastic Kubernetes Service (AWS EKS).

## Key features

1. Hyperconverged (all nodes have storage) or centralised (some nodes
have storage), Kubernetes-native storage on any infrastructure - use the
same code and storage features in-cloud and on-premises!
1. Best-in-class performance, availability and security - individually
encrypted volumes, performs better than competitors and synchronizes replicas
quickly and efficiently.
1. NFS (RWX) support allowing for performant sharing of volumes across multiple
workloads.
1. Free tier with 1TiB of storage under management plus unlimited replicas
1. Larger storage capacity and business support available in paid product

Find out more in our [documentation](https://docs.ondat.io/docs/concepts/)!

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace.ondat](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.storageos](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.etcd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_storage_class.etcd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | `any` | n/a | yes |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Password for the Ondat admin user | `string` | `"storageos"` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Username for the Ondat admin user | `string` | `"storageos"` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | Determines if the StorageOSCluster and secrets should be created | `bool` | `true` | no |
| <a name="input_etcd_ca"></a> [etcd\_ca](#input\_etcd\_ca) | The PEM encoded CA for Ondat's etcd | `string` | `null` | no |
| <a name="input_etcd_cert"></a> [etcd\_cert](#input\_etcd\_cert) | The PEM encoded client certificate for Ondat's etcd | `string` | `null` | no |
| <a name="input_etcd_endpoints"></a> [etcd\_endpoints](#input\_etcd\_endpoints) | A list of etcd endpoints for Ondat | `list(string)` | `[]` | no |
| <a name="input_etcd_key"></a> [etcd\_key](#input\_etcd\_key) | The PEM encoded client key for Ondat's etcd | `string` | `null` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for the ondat addon | `any` | `{}` | no |
| <a name="input_irsa_permissions_boundary"></a> [irsa\_permissions\_boundary](#input\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary | `string` | `""` | no |
| <a name="input_irsa_policies"></a> [irsa\_policies](#input\_irsa\_policies) | IAM policy ARNs for Ondat IRSA | `list(string)` | `[]` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
