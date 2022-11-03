# Core Concepts

This document provides a high level overview of the Core Concepts that are embedded in EKS Blueprints. For the purposes of this document, we will assume the reader is familiar with Git, Docker, Kubernetes and AWS.

| Concept                     | Description                                                                                   |
| --------------------------- | --------------------------------------------------------------------------------------------- |
| [Cluster](#cluster)         | An Amazon EKS Cluster and associated worker groups.                                           |
| [Add-on](#add-on)           | Operational software that provides key functionality to support your Kubernetes applications. |
| [Team](#team)               | A logical grouping of IAM identities that have access to Kubernetes resources.                |
| Pipeline                    | Continuous Delivery pipelines for deploying `clusters` and `add-ons`.                         |
| [Application](#application) | An application that runs within an EKS Cluster.                                               |

## Cluster

A `cluster` is simply an EKS cluster. EKS Blueprints provides for customizing the compute options you leverage with your `clusters`. The framework currently supports `EC2`, `Fargate` and `BottleRocket` instances. It also supports managed and self-managed node groups. To specify the type of compute you want to use for your `cluster`, you use the `managed_node_groups`, `self_managed_nodegroups`, or `fargate_profiles` variables.

## Add-on

`Add-ons` allow you to configure the operational tools that you would like to deploy into your EKS cluster. When you configure `add-ons` for a `cluster`, the `add-ons` will be provisioned at deploy time by leveraging the Terraform Helm provider. Add-ons can deploy both Kubernetes specific resources and AWS resources needed to support add-on functionality.

For example, the `metrics-server` add-on only deploys the Kubernetes manifests that are needed to run the Kubernetes Metrics Server. By contrast, the `aws-load-balancer-controller` add-on deploys both Kubernetes YAML, in addition to creating resources via AWS APIs that are needed to support the AWS Load Balancer Controller functionality.

EKS Blueprints allows you to manage your add-ons directly via Terraform (by leveraging the Terraform Helm provider) or via GitOps with ArgoCD. See our [`Add-ons`](add-ons/index.md) documentation page for detailed information.

## Team

`Teams` allow you to configure the logical grouping of users that have access to your EKS clusters, in addition to the access permissions they are granted. EKS Blueprints currently supports two types of `teams`: `application-team` and `platform-team`. `application-team` members are granted access to specific namespaces. `platform-team` members are granted administrative access to your clusters.

See our [`Teams`](teams.md) documentation page for detailed information.

## Application

`Applications` represent the actual workloads that run within a Kubernetes cluster. The framework leverages a GitOps approach for deploying applications onto clusters.

See our [`Applications`](https://aws-ia.github.io/terraform-aws-eks-blueprints/latest/add-ons/argocd/#bootstrapping) documentation for detailed information.
