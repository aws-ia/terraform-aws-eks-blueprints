# Amazon EKS SSP for Terraform

![GitHub](https://img.shields.io/github/license/aws-samples/aws-eks-accelerator-for-terraform)

Welcome to the Amazon EKS Shared Services Platform (SSP) for Terraform.

This repository contains the source code for a Terraform framework that aims to accelerate the delivery of a batteries-included, multi-tenant container platform on top of Amazon EKS. This framework can be used by AWS customers, partners, and internal AWS teams to implement the foundational structure of a SSP according to AWS best practices and recommendations.

This project leverages the community [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) modules for deploying EKS Clusters.

## Getting Started

The easiest way to get started with this framework is to follow our [Getting Started guide](./docs/getting-started.md).

## Documentation

For complete project documentation, please see our [official project documentation site](https://aws-quickstart.github.io/terraform-ssp-amazon-eks).

## Patterns

To view a library of examples for how you can leverage this framework, please see our [SSP Patterns](https://github.com/aws-ia/terraform-ssp-eks-patterns) repository.

You can also find an expanded sample implementation that resides in this repository in the `examples` directory.

## Usage Example

The below demonstrates how you can leverage this framework to deploy an EKS cluster, a managed node group, and various Kubernetes add-ons.

```hcl
module "eks-ssp" {
    source = "git@github.com:aws-samples/aws-eks-accelerator-for-terraform.git"

    # EKS CLUSTER
    cluster_name             = "test-eks-cluster"
    kubernetes_version       = "1.21"

    # EKS MANAGED ADD-ON VARIABLES
    enable_vpc_cni_addon     = true
    enable_coredns_addon     = true
    enable_kube_proxy_addon  = true

    # EKS ADD-ON VARIABLES
    aws_for_fluent_bit_enable           = true
    aws_lb_ingress_controller_enable    = true
    cert_manager_enable                 = true
    cluster_autoscaler_enable           = true
    metrics_server_enable               = true
    nginx_ingress_controller_enable     = true

    # EKS MANAGED NODE GROUPS
    enable_managed_nodegroups = true # default false
    managed_node_groups = {
        mg_4 = {
            node_group_name = "managed-ondemand"
            instance_types  = ["m4.large"]
            subnet_ids      = module.aws_vpc.private_subnets
        }
    }
}
```

The code above will provision the following:

✅  A new VPC with public and private subnets.\
✅  A new EKS Cluster with a managed node group.\
✅  EKS managed add-ons `vpc-cni`, `CoreDNS`, and `kube-proxy`.\
✅  `Fluent Bit` for routing metrics.\
✅  `AWS Load Balancer Controller` for distributing traffic.\
✅  `Cluster Autoscaler` and `Metrics Server` for scaling your workloads.\
✅  `cert-manager` for managing SSL/TLS certificates.\
✅  `Nginx` for managing ingress.

## Add-ons

This framework provides out of the box support for a wide range of popular Kubernetes add-ons. By default, the [Terraform Helm provider](https://github.com/hashicorp/terraform-provider-helm) is used to deploy add-ons with publicly available [Helm Charts](https://artifacthub.io/). The framework provides support however for leveraging self-hosted Helm Chart as well.

For complete documentation on deploying add-ons, please visit our [add-on documentation](./docs/add-ons/index.md)

## Submodules

The root module calls into several submodules which provides support for deploying and integrating a number of external AWS services that can be used in concert with EKS. This included Amazon Managed Prometheus and EMR with EKS etc.

For complete documentation on deploying external services, please visit our submodules documentation.

## Motivation

The Amazon EKS SSP for Terraform allows customers to easily configure and deploy a multi-tenant, enterprise-ready container platform on top of EKS. With a large number of design choices, deploying production-grade container platform can take a significant about of time, involve integrating a wide range or AWS services and open source tools, and require deep understand of AWS and Kubernetes concepts.

This solution handles integrating EKS with popular open source and partner tools, in addition to AWS services, in order to allow customers to deploy a cohesive container platform that can be offered as a service to application teams. It provides out-of-the-box support for common operational tasks such as auto-scaling workloads, collecting logs and metrics from both clusters and running applications, managing ingress and egress, configuring network policy, managing secrets, deploying workloads via GitOps, and more. Customers can leverage the solution to deploy a container platform and start onboarding workloads in days, rather than months.

## Feedback

For architectural details, step-by-step instructions, and customization options, see our official documentation site.

To post feedback, submit feature ideas, or report bugs, use the Issues section of this GitHub repo.

To submit code for this Quick Start, see the AWS Quick Start Contributor's Kit.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
