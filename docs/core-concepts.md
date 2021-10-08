# Core Concepts

This document provides a high level overview of the Core Concepts that are embedded in the `terraform-ssp-amazon-eks` framework. For the purposes of this document, we will assume the reader is familiar with Git, Docker, Kubernetes and AWS.

| Concept       | Description                                                           |
|---------------|-----------------------------------------------------------------------|
| [Cluster](#cluster) | A Well-Architected EKS Cluster. |
| [Add-on](#add-on) |  Allow you to configure, deploy, and update the operational software, or add-ons, that provide key functionality to support your Kubernetes applications. |
| [Team](#team) | A logical grouping of IAM identities that have access to a Kubernetes namespace(s). |
| [Pipeline](#pipeline) | Continuous Delivery pipelines for deploying `clusters` and `add-ons`. |
| [Application](#application) | An application that runs within an EKS Cluster. |

## Cluster

A `cluster` is simply an EKS cluster. The `terraform-ssp-amazon-eks` framework provides for customizing the compute options you leverage with your `clusters`. The framework currently supports `EC2`, `Fargate` and `BottleRocket` instances. It also supports managed and self-managed node groups. To specify the type of compute you want to use for your `cluster`, you use the `enable_managed_nodegroups`, `enable_self_managed_nodegroups`, or `enable_fargate` variables.

See our [Node Groups](./node-groups) documentation page for detailed information.

## Add-on

`Add-ons` allow you to configure the operational tools that you would like to deploy into your EKS cluster. When you configure `add-ons` for a `cluster`, the `add-ons` will be provisioned at deploy time by leveraging the Terraform Helm provider. Add-ons can deploy both Kubernetes specific resources and AWS resources needed to support add-on functionality.

For examples, the `metrics-server` add-on only deploys the Kubernetes manifests that are needed to run the Kubernetes Metrics Server. By contrast, the `aws-load-balancer-controller` add-on deploys both Kubernetes YAML, in addition to creating resources via AWS APIs that are needed to support the AWS Load Balancer Controller functionality.

See our [`Add-ons`](./add-ons) documentation page for detailed information.

## Team

** Team Support is currently under development **

`Teams` allow you to configure the logical grouping of users that have access to your EKS clusters, in addition to the access permissions they are granted. This framework currently supports two types of `teams`: `application-team` and `platform-team`. `application-team` members are granted access to specific namespaces. `platform-team` members are granted administrative access to your clusters.

See our [`Teams`](../teams) documentation page for detailed information.

## Pipeline

** Pipeline support is currently under development **

`Pipelines` allow you to configure `Continuous Delivery` (CD) pipelines for your EKS environments that are directly integrated with your Git provider.

See our [`Pipelines`](../pipelines) documentation page for detailed information.

## Application

`Applications` represent the actual workloads that run within a Kubernetes cluster. The framework leverages a GitOps approach for deploying applications onto clusters.

See our [`Applications](../applications) documentation for detailed information.
