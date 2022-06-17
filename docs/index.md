# Amazon EKS Blueprints for Terraform

![GitHub](https://img.shields.io/github/license/aws-ia/terraform-aws-eks-blueprints)

Welcome to Amazon EKS Blueprints for Terraform!

This repository contains a collection of Terraform modules that aim to make it easier and faster for customers to adopt [Amazon EKS](https://aws.amazon.com/eks/).

## What is EKS Blueprints

EKS Blueprints helps you compose complete EKS clusters that are fully bootstrapped with the operational software that is needed to deploy and operate workloads. With EKS Blueprints, you describe the configuration for the desired state of your EKS environment, such as the control plane, worker nodes, and Kubernetes add-ons, as an IaC blueprint. Once a blueprint is configured, you can use it to stamp out consistent environments across multiple AWS accounts and Regions using continuous deployment automation.

You can use EKS Blueprints to easily bootstrap an EKS cluster with Amazon EKS add-ons as well as a wide range of popular open-source add-ons, including Prometheus, Karpenter, Nginx, Traefik, AWS Load Balancer Controller, Fluent Bit, Keda, ArgoCD, and more. EKS Blueprints also helps you implement relevant security controls needed to operate workloads from multiple teams in the same cluster.

## Examples

To view a library of examples for how you can leverage `terraform-aws-eks-blueprints`, please see our [examples](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples).

## Workshop
We maintain a hands-on self-paced workshop, the [EKS Blueprints for Terraform workshop](https://catalog.workshops.aws/eks-blueprints-terraform/en-US) helps you with foundational setup of your EKS cluster, and it gradually adds complexity via existing and new modules.

![EKS Blueprints for Terraform](https://static.us-east-1.prod.workshops.aws/public/6ad9b13b-df6a-4609-a586-fd2b7f25863c/static/eks_cluster_1.svg)


## Motivation

Kubernetes is a powerful and extensible container orchestration technology that allows you to deploy and manage containerized applications at scale. The extensible nature of Kubernetes also allows you to use a wide range of popular open-source tools, commonly referred to as add-ons, in Kubernetes clusters. With such a large number of tooling and design choices available however, building a tailored EKS cluster that meets your application’s specific needs can take a significant amount of time. It involves integrating a wide range of open-source tools and AWS services and requires deep expertise in AWS and Kubernetes.

AWS customers have asked for examples that demonstrate how to integrate the landscape of Kubernetes tools and make it easy for them to provision complete, batteries-included EKS clusters that meet specific application requirements. EKS Blueprints was built to address this customer need. You can use EKS Blueprints to configure and deploy purpose built EKS clusters, and start onboarding workloads in days, rather than months.

## What can I do with this Solution?

Customers can use this solution to easily architect and deploy complete, opinionated EKS clusters. Specifically, customers can leverage the eks-blueprints module to:

- Deploy Well-Architected EKS clusters across any number of accounts and regions.
- Manage cluster configuration, including add-ons that run in each cluster, from a single Git repository.
- Define teams, namespaces, and their associated access permissions for your clusters.
- Leverage GitOps-based workflows for onboarding and managing workloads for your teams.
- Create Continuous Delivery (CD) pipelines that are responsible for deploying your infrastructure.
