# Extensibility

This guide provides an overview of extensibility options focusing on add-on extensions as the primary mechanism for the partners and customers.

## Overview

EKS Blueprints framework is designed to be extensible. In the context of this guide, extensibility refers to the ability of customers and partners to both add new capabilities to the framework or platforms as well as customize existing behavior, including the ability to modify or override existing behavior.

As of this writing, the primary means by which customers and partners can extend the EKS Blueprints for Terraform framework is by implementing new add-ons which could be leveraged exactly the same way as the core add-ons (supplied by the framework).

### Add-on Extensions

#### Helm Add-ons

Helm add-ons are the most common case that generally combines provisioning of a helm chart as well as supporting infrastructure such as wiring of proper IAM policies for the Kubernetes service account, provisioning or configuring other AWS resources (VPC, subnets, node groups).

In order to simplify the add-on creation, we have provided a helper module called [`helm-addon`](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/helm-addon/README.md) for convenience.

#### Non-helm Add-ons

Add-ons that don't leverage helm but require to install arbitrary Kubernetes manifests will not be able to leverage the benefits provided by the [`helm-addon`](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/helm-addon/README.md) however, they are still relatively easy to implement and would follow a similar pattern. Such addons should leverage the [kubectl provider](https://registry.terraform.io/providers/gavinbunney/kubectl).

### Public Add-ons

The life-cycle of a public add-on should be decoupled from the life-cycle of the core framework repository. When decoupled, extensions can be released at any arbitrary cadence specific to the extension, enabling better agility when it comes to new features or bug fixes. The owner of such public add-on is ultimately responsible for the quality and maintenance of the add-on.

In order to enable this model the following workflow outline steps required to create and release a public add-on:

1. Public add-on are created in a separate repository. Public GitHub repository is preferred as it aligns with the open-source spirit of the framework and enables external reviews/feedback.
2. Add-ons are released and consumed as distinct public Terraform modules.
3. Public add-ons are expected to have sufficient documentation to allow customers to consume them independently. Documentation can reside in GitHub or external resources referenced in the documentation bundled with the extension.
4. Public add-ons are expected to be tested and validated against released EKS Blueprints versions, e.g. with a CI/CD pipeline or GitHub Actions.

### Partner Add-ons

Partner extensions (APN Partner) are expected to comply with the public extension workflow and additional items required to ensure proper validation and documentation support for a partner extension.

We expect 2 PRs to be created for every Partner Add-On.

1. A PR against the main [EKS Blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints) repository that contains the following:
   1. Update [kubernetes-addons/main.tf](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/main.tf) to add a module invocation of the remote terraform module for the add-on.
   2. Documentation to update the [Add-Ons](./add-ons/index.md) section. Example of add-on documentation can be found here along with the list of other add-ons.
2. A second PR against the [EKS Blueprints Add-Ons](https://github.com/aws-samples/eks-blueprints-add-ons) repository to create an ArgoCD application for your add-on. See example of other add-ons that shows what should be added. Add-ons that do not provide GitOps support are not expected to create this PR.

### Private Add-ons

There are two ways in which a customer can implement fully private add-ons:

1. Add-ons specific to a customer instance of EKS Blueprints can be implemented inline with the blueprint in the same codebase. Such extensions are scoped to the customer base. Forking the repo however has disadvantages when it comes to ongoing feature releases and bug fixes which will have to be manually ported to your fork.
2. We recommend, you implement a separate repository for your private add-on while still using the upstream framework. This gives you the advantage of keeping up with ongoing feature releases and bug fixes while keeping your add-on private.

The following example shows you can leverage EKS Blueprints to provide your own helm add-on.

```hcl
#---------------------------------------------------------------
# AWS VPC CNI Metrics Helper
# This is using local helm chart
#---------------------------------------------------------------

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}


locals {
  cni_metrics_name = "cni-metrics-helper"

  default_helm_values = [templatefile("${path.module}/helm-values/cni-metrics-helper-values.yaml", {
    eks_cluster_id = var.eks_cluster_id,
    image          = "602401143452.dkr.ecr.${var.region}.amazonaws.com/cni-metrics-helper:v1.10.3",
    sa-name        = local.cni_metrics_name
   oidc_url        = "oidc.eks.eu-west-1.amazonaws.com/id/E6CASOMETHING55B9D01F7"
  })]

  addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = data.aws_eks_cluster.cluster.endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = var.region
    eks_cluster_id                 = var.eks_cluster_id
    eks_oidc_issuer_url            = local.oidc_url
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_url}"
    tags                           = {}
  }

  helm_config = {
    name        = local.cni_metrics_name
    description = "CNI Metrics Helper Helm Chart"
    timeout     = "300"
    chart       = "${path.module}/local-helm-charts/cni-metrics-helper"
    version     = "0.1.7"
    repository  = null
    namespace   = "kube-system"
    lint        = false
    values      = local.default_helm_values
  }

  irsa_config = {
    kubernetes_namespace              = "kube-system"
    kubernetes_service_account        = local.cni_metrics_name
    create_kubernetes_namespace       = false
    create_kubernetes_service_account = true
    irsa_iam_policies                 = [aws_iam_policy.cni_metrics.arn]
  }
}

module "helm_addon" {
  source      = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon"
  helm_config = local.helm_config
  irsa_config = local.irsa_config
  addon_context = local.addon_context
}

resource "aws_iam_policy" "cni_metrics" {
  name        = "${var.eks_cluster_id}-cni-metrics"
  description = "IAM policy for EKS CNI Metrics helper"
  path        = "/"
  policy      = data.aws_iam_policy_document.cni_metrics.json

  tags = var.tags
}

data "aws_iam_policy_document" "cni_metrics" {
  statement {
    sid = "CNIMetrics"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }
}
```

### Secrets Handling

We expect that certain add-ons will need to provide access to sensitive values to their helm chart configuration such as password, license keys, API keys, etc. We recommend that you ask customers to store such secrets in an external secret store such as AWS Secrets Manager or AWS Systems Manager Parameter Store and use the [AWS Secrets and Configuration Provider (ASCP)](https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html) to mount the secrets as files or environment variables in the pods of your add-on. We are actively working on providing a native add-on for ASCP as of this writing which you will be able to leverage for your add-on.

## Example Public Add-On

[Kube-state-metrics-addon](https://registry.terraform.io/modules/askulkarni2/kube-state-metrics-addon/eksblueprints/latest) extension contains a sample implementation of the [`kube-state-metrics`](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics) that demonstrates how to write a public add-on that lives outside of the core repo.

### Add-On Repo

We recommend the use of pattern `terraform-eksblueprints-<addon_name>` as the name of the repo so that you are able to easily publish the module to Terraform [registry](https://registry.terraform.io/). See [kube-state-metrics](https://github.com/askulkarni2/terraform-eksblueprints-kube-state-metrics-addon) for an example.

### Add-On Code

We recommend your add-on code follow Terraform standards for best practices for organizing your code, such as..

```sh
.
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── blueprints
│   ├── README.md
│   ├── addons
│   │   ├── README.md
│   │   ├── addons.tfbackend
│   │   ├── backend.tf
│   │   ├── data.tf
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   ├── eks
│   │   ├── README.md
│   │   ├── backend.tf
│   │   ├── data.tf
│   │   ├── eks.tfbackend
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   ├── vars
│   │   └── config.tfvars
│   └── vpc
│       ├── README.md
│       ├── backend.tf
│       ├── data.tf
│       ├── locals.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── variables.tf
│       └── vpc.tfbackend
├── locals.tf
├── main.tf
├── outputs.tf
├── values.yaml
└── variables.tf
```

In the above code tree,

- The root directory contains your add-on code.
- The blueprints code contains the code that demonstrates how customers can use your add-on with the EKS Blueprints framework. Here, we highly recommend that you show the true value add of your add-on through the pattern. Customers will benefit the most where the example shows how they can integrate their workload with your add-on.

If your add-on can be deployed via helm chart, we recommend the use of the [helm-addon](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/helm-addon) as shown below.

**Note**: Use the latest published module in the source version.

> main.tf

```hcl
module "helm_addon" {
  source               = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons/helm-addon?ref=v3.5.0"
  manage_via_gitops    = var.manage_via_gitops

  ### The following values are defined in locals.tf
  set_values           = local.set_values
  set_sensitive_values = local.set_sensitive_values
  helm_config          = local.helm_config
  addon_context        = var.addon_context
}
```

### Core Repo Changes

Once you have tested your add-on locally against your fork of the core repo, please open a PR that contains the following:

> Update to [`kubernetes-addons/main.tf`](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/main.tf) with a code block that invokes your add-on. E.g.

```hcl
module "kube_state_metrics" {
  count                     = var.enable_kube_state_metrics ? 1 : 0
  source                    = "askulkarni2/kube-state-metrics-addon/eksblueprints"
  version                   = "0.0.2"
  helm_config               = var.kube_state_metrics_helm_config
  addon_context             = local.addon_context
  manage_via_gitops         = var.argocd_manage_add_ons
}
```

> Update to [`kubernetes-addons/variables.tf`](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/variables.tf) to accept parameters for your add-on. E.g.

```hcl
#-----------Kube State Metrics ADDON-------------
variable "enable_kube_state_metrics" {
  type        = bool
  default     = false
  description = "Enable Kube State Metrics add-on"
}

variable "kube_state_metrics_helm_config" {
  type        = any
  default     = {}
  description = "Kube State Metrics Helm Chart config"
}
```

- Add documentation under add-on [`docs`](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/docs/add-ons/) that gives an overview of your add-on and points the customer to the actual documentation which would live in your add-on repo.

### GitOps

If your add-on can be managed via ArgoCD GitOps, then

- Provide the `argo_gitops_config` as an output of your add-on module as shown [here](https://github.com/askulkarni2/terraform-eksblueprints-kube-state-metrics-addon/blob/main/outputs.tf).

> outputs.tf

```hcl
output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? local.argocd_gitops_config : null
}
```

- In the PR against the core repo, update [`kubernetes-addons/locals.tf`](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/locals.tf) to provide the add-on module output `argocd_gitops_config` to the `argocd_add_on_config` as shown for others.

- Open a PR against the [eks-blueprints-addons](https://github.com/aws-samples/eks-blueprints-add-ons) repo with the following changes:

  - Create a wrapper Helm chart for your add-on similar to [kube-state-metrics](https://github.com/aws-samples/eks-blueprints-add-ons/tree/main/add-ons/kube-state-metrics)
    - Create a [`Chart.yaml`](https://github.com/aws-samples/eks-blueprints-add-ons/blob/main/add-ons/kube-state-metrics/Chart.yaml) which points to the location of your actual helm chart.
    - Create a [`values.yaml`](https://github.com/aws-samples/eks-blueprints-add-ons/blob/main/add-ons/kube-state-metrics/values.yaml) which contains a default best-practice configuration for your add-on.
  - Create an ArgoCD application [template](https://github.com/aws-samples/eks-blueprints-add-ons/blob/main/chart/templates/kube-state-metrics.yaml) which is applied if `enable_<add_on> = true` is used by the customer in the consumer module. This also used to parameterize your add-ons helm chart wrapper with values that will be passed over from Terraform to Helm using the [GitOps bridge](./add-ons/index.md#gitops-bridge).
