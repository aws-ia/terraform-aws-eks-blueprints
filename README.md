# Amazon EKS Blueprints for Terraform

[![plan-examples](https://github.com/aws-ia/terraform-aws-eks-blueprints/actions/workflows/plan-examples.yml/badge.svg)](https://github.com/aws-ia/terraform-aws-eks-blueprints/actions/workflows/plan-examples.yml)
[![pre-commit](https://github.com/aws-ia/terraform-aws-eks-blueprints/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/aws-ia/terraform-aws-eks-blueprints/actions/workflows/pre-commit.yml)

---

## :bangbang: Notice of Potential Breaking Changes in Version 5 :bangbang:

The direction for EKS Blueprints in v5 will shift from providing an all-encompassing, monolithic "framework" and instead focus more on how users can organize a set of modular components to create the desired solution on Amazon EKS.

The issue below was created to provide community notice and to help track progress, learn what's new and how the migration path would look like to upgrade your current Terraform deployments.

We welcome the EKS Blueprints community to continue the discussion in issue https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/1421

---

Welcome to Amazon EKS Blueprints for Terraform!

This project contains a collection of Amazon EKS cluster patterns implemented in Terraform that demonstrate how fast and easy it is for customers to adopt [Amazon EKS](https://aws.amazon.com/eks/). The patterns can be used by AWS customers, partners, and internal AWS teams to configure and manage complete EKS clusters that are fully bootstrapped with the operational software that is needed to deploy and operate workloads.

## Getting Started

The easiest way to get started with EKS Blueprints is to follow our [Getting Started guide](https://aws-ia.github.io/terraform-aws-eks-blueprints/latest/getting-started/).

## Examples

To view examples for how you can leverage EKS Blueprints, please see the [examples](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples) directory.

## Motivation

Kubernetes is a powerful and extensible container orchestration technology that allows you to deploy and manage containerized applications at scale. The extensible nature of Kubernetes also allows you to use a wide range of popular open-source tools, commonly referred to as add-ons, in Kubernetes clusters. With such a large number of tooling and design choices available however, building a tailored EKS cluster that meets your application’s specific needs can take a significant amount of time. It involves integrating a wide range of open-source tools and AWS services and requires deep expertise in AWS and Kubernetes.

AWS customers have asked for examples that demonstrate how to integrate the landscape of Kubernetes tools and make it easy for them to provision complete, opinionated EKS clusters that meet specific application requirements. Customers can use EKS Blueprints to configure and deploy purpose built EKS clusters, and start onboarding workloads in days, rather than months.

## Support & Feedback

EKS Blueprints for Terraform is maintained by AWS Solution Architects. It is not part of an AWS service and support is provided best-effort by the EKS Blueprints community. To post feedback, submit feature ideas, or report bugs, please use the [Issues section](https://github.com/aws-ia/terraform-aws-eks-blueprints/issues) of this GitHub repo. If you are interested in contributing to EKS Blueprints, see the [Contribution guide](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/CONTRIBUTING.md).

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/LICENSE).
