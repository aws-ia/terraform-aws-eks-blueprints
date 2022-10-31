# Amazon EKS Blueprints for Terraform

[![e2e-terratest](https://github.com/aws-ia/terraform-aws-eks-blueprints/actions/workflows/e2e-terratest.yml/badge.svg)](https://github.com/aws-ia/terraform-aws-eks-blueprints/actions/workflows/e2e-terratest.yml)
[![plan-examples](https://github.com/aws-ia/terraform-aws-eks-blueprints/actions/workflows/plan-examples.yml/badge.svg)](https://github.com/aws-ia/terraform-aws-eks-blueprints/actions/workflows/plan-examples.yml)
[![pre-commit](https://github.com/aws-ia/terraform-aws-eks-blueprints/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/aws-ia/terraform-aws-eks-blueprints/actions/workflows/pre-commit.yaml)

Welcome to Amazon EKS Blueprints for Terraform!

This repository contains a collection of Terraform modules that aim to make it easier and faster for customers to adopt [Amazon EKS](https://aws.amazon.com/eks/). It can be used by AWS customers, partners, and internal AWS teams to configure and manage complete EKS clusters that are fully bootstrapped with the operational software that is needed to deploy and operate workloads.

This project leverages the community [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) modules for deploying EKS Clusters.

## Getting Started

The easiest way to get started with EKS Blueprints is to follow our [Getting Started guide](https://aws-ia.github.io/terraform-aws-eks-blueprints/latest/getting-started/).

## Documentation

For complete project documentation, please visit our [documentation site](https://aws-ia.github.io/terraform-aws-eks-blueprints/).

## Examples

To view examples for how you can leverage EKS Blueprints, please see the [examples](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples) directory.

## Add-ons

EKS Blueprints makes it easy to provision a wide range of popular Kubernetes add-ons into an EKS cluster. By default, the [Terraform Helm provider](https://github.com/hashicorp/terraform-provider-helm) is used to deploy add-ons with publicly available [Helm Charts](https://artifacthub.io/).EKS Blueprints provides support for leveraging self-hosted Helm Chart as well.

For complete documentation on deploying add-ons, please visit our [add-on documentation](https://aws-ia.github.io/terraform-aws-eks-blueprints/latest/add-ons/)

## Motivation

Kubernetes is a powerful and extensible container orchestration technology that allows you to deploy and manage containerized applications at scale. The extensible nature of Kubernetes also allows you to use a wide range of popular open-source tools, commonly referred to as add-ons, in Kubernetes clusters. With such a large number of tooling and design choices available however, building a tailored EKS cluster that meets your application’s specific needs can take a significant amount of time. It involves integrating a wide range of open-source tools and AWS services and requires deep expertise in AWS and Kubernetes.

AWS customers have asked for examples that demonstrate how to integrate the landscape of Kubernetes tools and make it easy for them to provision complete, opinionated EKS clusters that meet specific application requirements. Customers can use EKS Blueprints to configure and deploy purpose built EKS clusters, and start onboarding workloads in days, rather than months.

## Support & Feedback

EKS Blueprints for Terraform is maintained by AWS Solution Architects. It is not part of an AWS service and support is provided best-effort by the EKS Blueprints community.
To post feedback, submit feature ideas, or report bugs, please use the [Issues section](https://github.com/aws-ia/terraform-aws-eks-blueprints/issues) of this GitHub repo.
If you are interested in contributing to EKS Blueprints, see the [Contribution guide](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/CONTRIBUTING.md).

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/LICENSE).
