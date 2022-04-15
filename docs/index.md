# Amazon EKS Blueprints for Terraform

![GitHub](https://img.shields.io/github/license/aws-ia/terraform-aws-eks-blueprints)

Welcome to the Amazon EKS Blueprints for Terraform

This repository contains the source code for a Terraform module that aims to accelerate the delivery of a batteries-included, multi-tenant container platform on top of Amazon EKS. This solution can be used by AWS Customers, Partners, and internal AWS teams to implement the foundational structure of an EKS Blueprint according to AWS best practices and recommendations.

## Motivation

The Amazon EKS Blueprints for Terraform allows customers to easily configure and deploy a multi-tenant, enterprise-ready container platform on top of EKS. With a large number of design choices, deploying production-grade container platform can take a significant about of time, involve integrating a wide range or AWS services and open source tools, and require deep understand of AWS and Kubernetes concepts.

This solution handles integrating EKS with popular open source and partner tools, in addition to AWS services, in order to allow customers to deploy a cohesive container platform that can be offered as a service to application teams. It provides out-of-the-box support for common operational tasks such as auto-scaling workloads, collecting logs and metrics from both clusters and running applications, managing ingress and egress, configuring network policy, managing secrets, deploying workloads via GitOps, and more. Customers can leverage the solution to deploy a container platform and start onboarding workloads in days, rather than months.

## What can I do with this Solution?

Customers can use this solution to easily architect and deploy a multi-tenant blueprint built on EKS. Specifically, customers can leverage the eks-blueprints module to:

✅ Deploy Well-Architected EKS clusters across any number of accounts and regions.

✅ Manage cluster configuration, including add-ons that run in each cluster, from a single Git repository.

✅ Define teams, namespaces, and their associated access permissions for your clusters.

✅ Create Continuous Delivery (CD) pipelines that are responsible for deploying your infrastructure.

✅ Leverage GitOps-based workflows for onboarding and managing workloads for your teams.

## Examples

To view a library of examples for how you can leverage the terraform-eks-blueprints, please see our [examples](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples).
