# Extensibility

This guide provides an overview of extensibility options focusing on add-on extensions as the primary mechanism for the partners and customers.

## Overview

SSP Framework is designed to be extensible. In the context of this guide, extensibility refers to the ability of customers and partners to both add new capabilities to the framework or platforms based on SSP as well as customize existing behavior, including the ability to modify or override existing behavior.

As of this writing, the primary means by which customers and partners can extend the framework is by implementing new add-ons which could be leveraged exactly the same way as the core add-ons (supplied by the framework).

### Add-on Extensions

#### Helm Add-ons

Helm add-ons are the most common case that generally combines provisioning of a helm chart as well as supporting infrastructure such as wiring of proper IAM policies for the Kubernetes service account, provisioning or configuring other AWS resources (VPC, subnets, node groups).

In order to simplify the add-on creation, we have provided a helper module called [`helm-addon`](../modules/kubernetes-addons/helm-addon/README.md).

#### Non-helm Add-ons

Add-ons that don't leverage helm but require to install arbitrary Kubernetes manifests will not be able to leverage the benefits provided by the [`helm-addon`](../modules/kubernetes-addons/helm-addon/README.md) however, they are still relatively easy to implement.

### Private Extensions

Extensions specific to a customer instance of SSPs can be implemented inline with the blueprint in the same codebase. Such extensions are scoped to the customer base and cannot be reused. Example of a private extension:


```hcl
```

### Public Extensions

The life-cycle of a public extension should be decoupled from the life-cycle of the SSP Quickstart main repository. When decoupled, extensions can be released at any arbitrary cadence specific to the extension, enabling better agility when it comes to new features or bug fixes.

In order to enable this model the following workflow outline steps required to create and release a public extension:

1. Public extensions are created in a separate repository. Public GitHub repository is preferred as it aligns with the open-source spirit of the framework and enables external reviews/feedback.
1. Extensions are released and consumed as distinct public Terraform modules.
1. Public Extensions are expected to have sufficient documentation to allow customers to consume them independently. Documentation can reside in GitHub or external resources referenced in the documentation bundled with the extension.
1. Public extensions are expected to be tested and validated against released SSP versions, e.g. with a CICD pipeline.

### Partner Extensions

Partner extensions (APN Partner) are expected to comply with the public extension workflow and additional items required to ensure proper validation and documentation support for a partner extension.

We expect 2 PRs to be created for every Partner Add-On.
1. A PR against the main [SSP Quickstart](https://github.com/aws-samples/aws-eks-accelerator-for-terraform) repository that contains the following:
   1. Update [kubernetes-addons](../modules/kubernetes-addons) to add a module invocation of the remote terraform module for the add-on.
   2. Documentation to update the [AddOns](./add-ons) section. Example of add-on documentation can be found here along with the list of other add-ons.
   3. An example that shows a ready to use pattern leveraging the add-on should be submitted to the [SSP Quickstart Examples](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/tree/main/examples). This step will enable AWS Partner Solution Architects to validate the add-on as well as provide a ready to use pattern to the customers, that could be copied/cloned in their SSP implementation.
2. A second PR against the [SSP Add-Ons](https://github.com/aws-samples/ssp-eks-add-ons) repository to create an ArgoCD application for your add-on. See example of other add-ons that shows what should be added.

### Example Extension

[Example](https://github.com/askulkarni2/kube-state-metrics-addon) extension contains a sample implementation of the [`kube-state-metrics`](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-state-metrics) add-on and covers the following aspects of an extension workflow:

1. Pre-requisite configuration related to terraform.
2. Project template with support to test and run the extension.
3. Example blueprint (can be found in ./example/main.tf) that references the add-on.
4. Example of the helm chart provisioning.
