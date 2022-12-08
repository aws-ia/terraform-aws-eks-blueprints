# Cert Manager Deployment Guide

## Introduction

Cert Manager adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates.

## Migrating to newer version
The older version of a chart was only creating `ClusterIssuer` resource with custom chart, path: `terraform-aws-eks-blueprints/modules/kubernetes-addons/cert-manager/cert-manager-letsencrypt`, so the `Certificate` resource should have been built by a user manually. Also the chart was based only on specific ACME Certificate Authority `Let's Encrypt`, based on some searches appeared that there are a bunch of ACME Certificate Authorities that can replace `Let's Encrypt`, such as `ZeroSSL`. Below will be the details of changes.
#### *Chart*:

Path: 
[terraform-aws-eks-blueprints/modules/kubernetes-addons/cert-manager/cert-manager-acme.](https://github.com/hakmkoyan/terraform-aws-eks-blueprints/tree/feat/cert-manager/modules/kubernetes-addons/cert-manager/cert-manager-acme) <br>
As you can notice the folder name changed from `cert-manager-letsencrypt` to `cert-manager-acme`, as now the chart is not only based on `Let's Encrypt`, but the user should determine what `ACME CA` it want to use.<br><br>

Path:
[terraform-aws-eks-blueprints/modules/kubernetes-addons/cert-manager/cert-manager-acme/Chart.yaml](https://github.com/hakmkoyan/terraform-aws-eks-blueprints/blob/feat/cert-manager/modules/kubernetes-addons/cert-manager/cert-manager-acme/Chart.yaml).<br>
Everything that was connected with the word 'lets encrypt' changed to `acme`, the version for chart changed from `0.1.0` to `0.2.0`.
<details>
<summary>File content</summary>
<p>
```yaml
apiVersion: v2
name: cert-manager-acme
description: Cert Manager Cluster Issuers for ACME certificates with DNS01 protocol
type: application
version: 0.2.0
appVersion: v0.1.0
```
</p>
</details>
<br><br>

Path:
[terraform-aws-eks-blueprints/modules/kubernetes-addons/cert-manager/cert-manager-acme/values.yaml](https://github.com/hakmkoyan/terraform-aws-eks-blueprints/blob/feat/cert-manager/modules/kubernetes-addons/cert-manager/cert-manager-acme/values.yaml).<br>
The values `email, region & dnsZones` *REMAINED* the same, the values `name, externalAccountBinding: {keyID: "", secretKey: ""}, preferredChain, acmeServerUrl, hostedZoneID, commonName, isCA` were *ADDED*.<br><br>

Path:
[terraform-aws-eks-blueprints/modules/kubernetes-addons/cert-manager/cert-manager-letsencrypt/templates](https://github.com/hakmkoyan/terraform-aws-eks-blueprints/tree/feat/cert-manager/modules/kubernetes-addons/cert-manager/cert-manager-acme/templates).<br>
As you can notice the files `clusterissuer-staging.yaml & clusterissuer-production.yaml` disappeared, *BUT* actually one of them was modified to generic `ACME` template. Now the `ClusterIssuer` template's `ACME CA endpoint` is not hardcoded to `lets encrypt's endpoint`, it will take its value from the user's variable.If now the user is able to choose its own `ACME CA`, from this there is the second problem that in some cases of ACME usage, like `ZeroSSL`, there would have been a problem to pass a credentials of `ACME CA` to `ClusterIssuer`. So the user is now able to pass a credentials of `ACME CA` to the chart with `externalAccountBinding`. Also the user now is able to select specific `hosted zone` for its Route53. More detailed keys are below.<br><br>

Path: [terraform-aws-eks-blueprints/modules/kubernetes-addons/cert-manager/cert-manager-acme/templates/acme-server-secretkey-secret.yaml](https://github.com/hakmkoyan/terraform-aws-eks-blueprints/blob/feat/cert-manager/modules/kubernetes-addons/cert-manager/cert-manager-acme/templates/acme-server-secretkey-secret.yaml).<br>
This is the `Secret` template of the `externalAccountBinding`, so the user could be able to deploy the `ACME CA's` credentials, with encoded `Secret` resource.<br><br>

Path: [terraform-aws-eks-blueprints/modules/kubernetes-addons/cert-manager/cert-manager-acme/templates/certificate.yaml](https://github.com/hakmkoyan/terraform-aws-eks-blueprints/blob/feat/cert-manager/modules/kubernetes-addons/cert-manager/cert-manager-acme/templates/certificate.yaml).<br>
In the previous version the `Certificate` resource was not deployed, it remained on the user to deploy that manifest manually, but now the user can pass the parameters of the `Certificate` resource and it will be created automatically with the chart, and will request the certificate.

#### *Terraform Module*:
Path: [terraform-aws-eks-blueprints/modules/kubernetes-addons/cert-manager/variables.tf](https://github.com/hakmkoyan/terraform-aws-eks-blueprints/blob/feat/cert-manager/modules/kubernetes-addons/cert-manager/variables.tf). <br>
The `install_letsencrypt_issuers & letsencrypt_email` *CHANGED* to `install_acme_issuers & email`, the `cluster_issuer_name, external_account_keyID, external_account_secret_key, preferred_chain, acme_server_url, dns_region, common_name, is_ca, dns_names, hosted_zone_id` were *ADDED*. More details of variables below.<br><br>

Path: [terraform-aws-eks-blueprints/modules/kubernetes-addons/cert-manager/main.tf](https://github.com/hakmkoyan/terraform-aws-eks-blueprints/blob/feat/cert-manager/modules/kubernetes-addons/cert-manager/main.tf). <br>
In the resource block `cert_manager_letsencrypt` everything named `letsencrypt` changed to `acme`. Added `set` blocks which will change the values of `cert-manager-acme` folder's `values.yaml` file. By default these variables matching to values with `set` block are empty `""` or if boolean, by default `false`.

## Helm Chart

### Instructions to use the Helm Chart

See the [cert-manager documentation](https://cert-manager.io/docs/installation/helm/).

# Docker Image for Cert Manager

cert-manager docker image is available at this repo:

<https://quay.io/repository/jetstack/cert-manager-controller?tag=latest&tab=tags>

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.10 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.10 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.4.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.cert_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [helm_release.cert_manager_ca](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert_manager_acme](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_iam_policy_document.cert_manager_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>  })</pre> | n/a | yes |
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | Domain names of the Route53 hosted zone to use with cert-manager. | `list(string)` | `[]` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | cert-manager Helm chart configuration | `any` | `{}` | no |
| <a name="input_install_acme_issuers"></a> [install\_acme\_issuers](#input\_install\_acme\_issuers) | Install ACME Cluster Issuers. | `bool` | `true` | no |
| <a name="input_irsa_policies"></a> [irsa\_policies](#input\_irsa\_policies) | Additional IAM policies used for the add-on service account. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_svc_image_pull_secrets"></a> [kubernetes\_svc\_image\_pull\_secrets](#input\_kubernetes\_svc\_image\_pull\_secrets) | list(string) of kubernetes imagePullSecrets | `list(string)` | `[]` | no |
| <a name="input_email"></a> [email](#input\_email) | Email address for expiration. | `string` | `""` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Prefix for cluster issuer and other resources. | `string` | `""` | no |
| <a name="input_external_account_keyID"></a> [external\_account\_keyID](#input\_external\_account\_keyID) | ID of the CA key that the External Account is bound to. | `"string"` | `""` | no |
| <a name="input_external_account_secret_key"></a> [external\_account\_secret\_key](#input\_external\_account\_secret\_key) | Secret key of the CA that the External Account is bound to. | `string` | `""` | no |
| <a name="input_preferred_chain"></a> [preferred\_chain](#input\_preferred\_chain) | Chain to use if the ACME server outputs multiple. | `string` | `""` | no |
| <a name="input_acme_server_url"></a> [acme\_server\_url](#input\_acme\_server\_url) | The URL used to access the ACME server's 'directory' endpoint. | `string` | `""` | no |
| <a name="input_dns_region"></a> [dns\_region](#input\_dns\_region) | DNS Region | `string` | `""` | no |
| <a name="input_common_name"></a> [common\_name](#input\_common\_name) | Common name to be used on the Certificate. | `string` | `""` | no |
| <a name="input_is_ca"></a> [is\_ca](#input\_is\_ca) | IsCA will mark this Certificate as valid for certificate signing. | `bool` | `true` | no |
| <a name="input_dns_names"></a> [dns\_names](#input\_dns\_names) | DNSNames is a list of DNS subjectAltNames to be set on the Certificate. | `list(string)` | `[""]` | no |
| <a name="hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | If set, the provider will manage only this zone in Route53 and will not do an lookup using the route53:ListHostedZonesByName api call. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | Current AWS EKS Cluster ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
