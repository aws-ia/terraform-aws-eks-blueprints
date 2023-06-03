# Amazon EKS Blueprints for Terraform

Welcome to Amazon EKS Blueprints for Terraform!

This project contains a collection of Amazon EKS cluster patterns implemented in Terraform that demonstrate how fast and easy it is for customers to adopt [Amazon EKS](https://aws.amazon.com/eks/). The patterns can be used by AWS customers, partners, and internal AWS teams to configure and manage complete EKS clusters that are fully bootstrapped with the operational software that is needed to deploy and operate workloads.

## Motivation

Kubernetes is a powerful and extensible container orchestration technology that allows you to deploy and manage containerized applications at scale. The extensible nature of Kubernetes also allows you to use a wide range of popular open-source tools, commonly referred to as add-ons, in Kubernetes clusters. With such a large number of tooling and design choices available however, building a tailored EKS cluster that meets your application’s specific needs can take a significant amount of time. It involves integrating a wide range of open-source tools and AWS services and requires deep expertise in AWS and Kubernetes.

AWS customers have asked for examples that demonstrate how to integrate the landscape of Kubernetes tools and make it easy for them to provision complete, opinionated EKS clusters that meet specific application requirements. Customers can use EKS Blueprints to configure and deploy purpose built EKS clusters, and start onboarding workloads in days, rather than months.

## Core Concepts

This document provides a high level overview of the Core Concepts that are embedded in EKS Blueprints. For the purposes of this document, we will assume the reader is familiar with Git, Docker, Kubernetes and AWS.

| Concept                     | Description                                                                                   |
| --------------------------- | --------------------------------------------------------------------------------------------- |
| [Cluster](#cluster)         | An Amazon EKS Cluster and associated worker groups.                                           |
| [Add-on](#add-on)           | Operational software that provides key functionality to support your Kubernetes applications. |
| [Team](#team)               | A logical grouping of IAM identities that have access to Kubernetes resources.                |

### Cluster

A `cluster` is simply an EKS cluster. EKS Blueprints provides for customizing the compute options you leverage with your `clusters`. The framework currently supports `EC2`, `Fargate` and `BottleRocket` instances. It also supports managed and self-managed node groups.

We rely on [`terraform-aws-modules/eks/aws`](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) to configure `clusters`. See our [examples](getting-started.md) to see how `terraform-aws-modules/eks/aws` is configured for EKS Blueprints.

### Add-on

`Add-ons` allow you to configure the operational tools that you would like to deploy into your EKS cluster. When you configure `add-ons` for a `cluster`, the `add-ons` will be provisioned at deploy time by leveraging the Terraform Helm provider. Add-ons can deploy both Kubernetes specific resources and AWS resources needed to support add-on functionality.

For example, the `metrics-server` add-on only deploys the Kubernetes manifests that are needed to run the Kubernetes Metrics Server. By contrast, the `aws-load-balancer-controller` add-on deploys both Kubernetes YAML, in addition to creating resources via AWS APIs that are needed to support the AWS Load Balancer Controller functionality.

EKS Blueprints allows you to manage your add-ons directly via Terraform (by leveraging the Terraform Helm provider) or via GitOps with ArgoCD. See our [`Add-ons`](https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/) documentation page for detailed information.

### Team

`Teams` allow you to configure the logical grouping of users that have access to your EKS clusters, in addition to the access permissions they are granted.

See our [`Teams`](https://github.com/aws-ia/terraform-aws-eks-blueprints-teams) documentation page for detailed information.

## Support & Feedback

EKS Blueprints for Terraform is maintained by AWS Solution Architects. It is not part of an AWS service and support is provided best-effort by the EKS Blueprints community. To post feedback, submit feature ideas, or report bugs, please use the [Issues section](https://github.com/aws-ia/terraform-aws-eks-blueprints/issues) of this GitHub repo. If you are interested in contributing to EKS Blueprints, see the [Contribution guide](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/CONTRIBUTING.md).

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/LICENSE).
