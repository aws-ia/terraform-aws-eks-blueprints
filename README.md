# Amazon EKS Blueprints for Terraform

Welcome to Amazon EKS Blueprints for Terraform!

This project contains a collection of Amazon EKS cluster patterns implemented in Terraform that
demonstrate how fast and easy it is for customers to adopt [Amazon EKS](https://aws.amazon.com/eks/).
The patterns can be used by AWS customers, partners, and internal AWS teams to configure and manage
complete EKS clusters that are fully bootstrapped with the operational software that is needed to
deploy and operate workloads.

## Motivation

Kubernetes is a powerful and extensible container orchestration technology that allows you to deploy
and manage containerized applications at scale. The extensible nature of Kubernetes also allows you
to use a wide range of popular open-source tools in Kubernetes clusters. However, With the wide array
of tooling and design choices available, configuring an EKS cluster that meets your organization’s
specific needs can take a significant amount of time. It involves integrating a wide range of
open-source tools and AWS services as well as expertise in AWS and Kubernetes.

AWS customers have asked for patterns that demonstrate how to integrate the landscape of Kubernetes
tools and make it easy for them to provision complete, opinionated EKS clusters that meet specific
application requirements. Customers can utilize EKS Blueprints to configure and deploy purpose-built
EKS clusters, and start onboarding workloads in days, rather than months.

## Consumption

EKS Blueprints for Terraform has been designed to be consumed in the following manners:

1. Reference: Users can refer to the patterns and snippets provided to help guide them to their desired
solution. Users will typically view how the pattern or snippet is configured to achieve the desired
end result and then replicate that in their environment.
2. Copy & Paste: Users can copy and paste the patterns and snippets into their own environment, using
EKS Blueprints as the starting point for their implementation. Users can then adapt the initial pattern
to customize it to their specific needs.

EKS Blueprints for Terraform are not intended to be consumed as-is directly from this project. In
"Terraform speak" - the patterns and snippets provided in this repository are not designed to be consumed
as a Terraform module. Therefore, the patterns provided only contain `variables` when certain information
is required to deploy the pattern (i.e. - a Route53 hosted zone ID, or ACM certificate ARN) and generally
use local variables. If you wish to deploy the patterns into a different region or with other changes, it
is recommended that you make those modifications locally before applying the pattern. EKS Blueprints for
Terraform will not expose variables and outputs in the same manner that Terraform modules follow in
order to avoid confusion around the consumption model.

However, we do have a number of Terraform modules that were created to support
EKS Blueprints in addition to the community-hosted modules. Please see the respective projects for more
details on the modules constructed to support EKS Blueprints for Terraform; those projects are listed
[below](https://aws-ia.github.io/terraform-aws-eks-blueprints/#related-projects).

- [`terraform-aws-eks-blueprint-addon`](https://github.com/aws-ia/terraform-aws-eks-blueprints-addon) -
(Note the singular form) Terraform module which can provision an addon using the Terraform
`helm_release` resource in addition to an IAM role for service account (IRSA).
- [`terraform-aws-eks-blueprint-addons`](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons) -
(Note the plural form) Terraform module which can provision multiple addons; both EKS addons
using the `aws_eks_addon` resource as well as Helm chart based addons using the
[`terraform-aws-eks-blueprint-addon`](https://github.com/aws-ia/terraform-aws-eks-blueprints-addon) module.
- [`terraform-aws-eks-blueprints-teams`](https://github.com/aws-ia/terraform-aws-eks-blueprints-teams) -
Terraform module that creates Kubernetes multi-tenancy resources and configurations, allowing both
administrators and application developers to access only the resources which they are responsible for.

### Related Projects

In addition to the supporting EKS Blueprints Terraform modules listed above, there are a number of
related projects that users should be aware of:

1. GitOps

    - [`terraform-aws-eks-ack-addons`](https://github.com/aws-ia/terraform-aws-eks-ack-addons) -
  Terraform module to deploy ACK controllers onto EKS clusters
    - [`crossplane-on-eks`](https://github.com/awslabs/crossplane-on-eks) - Crossplane Blueprints
    is an open-source repo to bootstrap Amazon EKS clusters and provision AWS resources using a
    library of Crossplane Compositions (XRs) with Composite Resource Definitions (XRDs).

2. Data on EKS

    - [`data-on-eks`](https://github.com/awslabs/data-on-eks) - A collection of blueprints intended
    for data workloads on Amazon EKS.
    - [`terraform-aws-eks-data-addons`](https://github.com/aws-ia/terraform-aws-eks-data-addons) -
    Terraform module to deploy multiple addons that are specific to data workloads on EKS clusters.

3. Observability Accelerator

    - [`terraform-aws-observability-accelerator`](https://github.com/aws-observability/terraform-aws-observability-accelerator) -
    A set of opinionated modules to help you set up observability for your AWS environments with
    AWS-managed observability services such as Amazon Managed Service for Prometheus, Amazon
    Managed Grafana, AWS Distro for OpenTelemetry (ADOT) and Amazon CloudWatch

4. Karpenter Blueprints
   - [`karpenter-blueprints`](https://github.com/aws-samples/karpenter-blueprints) - includes a list of common workload scenarios,
   some of which go in depth with the explanation of why configuring Karpenter and Kubernetes objects in such a way is important.

## Terraform Caveats

EKS Blueprints for Terraform does not intend to teach users the recommended practices for Terraform
nor does it offer guidance on how users should structure their Terraform projects. The patterns
provided are intended to show users how they can achieve a defined architecture or configuration
in a way that they can quickly and easily get up and running to start interacting with that pattern.
Therefore, there are a few caveats users should be aware of when using EKS Blueprints for Terraform:

1. We recognize that most users will already have an existing VPC in a separate Terraform workspace.
However, the patterns provided come complete with a VPC to ensure a stable, deployable example that
has been tested and validated.

2. Hashicorp [does not recommend providing computed values in provider blocks](https://github.com/hashicorp/terraform/issues/27785#issuecomment-780017326)
, which means that the cluster configuration should be defined in a workspace separate from the resources
deployed onto the cluster (i.e. - addons). However, to simplify the pattern experience, we have defined
everything in one workspace and provided instructions to provision the patterns using a targeted
apply approach. Users are encouraged to investigate a Terraform project structure that suits their needs;
EKS Blueprints for Terraform does not have an opinion in this matter and will defer to Hashicorp's guidance.

3. Patterns are not intended to be consumed in-place in the same manner that one would consume a module.
Therefore, we do not provide variables and outputs to expose various levels of configuration for the examples.
Users can modify the pattern locally after cloning to suit their requirements.

4. Please see the [FAQ section](https://aws-ia.github.io/terraform-aws-eks-blueprints/faq/#provider-authentication)
on authenticating Kubernetes-based providers (`kubernetes`, `helm`, `kubectl`) to Amazon EKS clusters
regarding the use of static tokens versus dynamic tokens using the `awscli`.

## Support & Feedback

EKS Blueprints for Terraform is maintained by AWS Solution Architects. It is not part of an AWS
service and support is provided as a best effort by the EKS Blueprints community. To provide feedback,
please use the [issues templates](https://github.com/aws-ia/terraform-aws-eks-blueprints/issues)
provided. If you are interested in contributing to EKS Blueprints, see the
[Contribution guide](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/CONTRIBUTING.md).

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

Apache-2.0 Licensed. See [LICENSE](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/LICENSE).
