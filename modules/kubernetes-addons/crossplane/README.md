# Crossplane
Crossplane is an open source Kubernetes add-on that enables platform teams to assemble infrastructure from multiple vendors, and expose higher level self-service APIs for application teams to consume, without having to write any code.

 - Crossplane is a control plane
 - Allow engineers to model their infrastructure as declarative configuration
 - Support managing a myriad of diverse infrastructure using "provider" plugins
 - It's an open source tool with strong communities

Please find more details from [Crossplane](https://crossplane.io/)

## Usage
Crossplane Add-on can be deployed as follows

```hcl
  enable_crossplane = true
```

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
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace_v1.irsa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for the Argo Rollouts | `any` | `{}` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |

<!--- END_TF_DOCS --->
