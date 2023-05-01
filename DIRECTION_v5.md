# Direction for v5 of Terraform EKS Blueprints

## What Has Worked

- EKS Blueprints was started to [make it easier for customers to adopt Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/blogs/containers/bootstrapping-clusters-with-eks-blueprints/) in a shorter period of time. The project has been quite successful in this regard - hearing from customers stating that EKS Blueprints has helped them get from zero to one or more clusters running with applications in less than 1-2 weeks.

- EKS Blueprints has also been successful in providing working examples to users that demonstrate common architectural patterns and workload solutions. Some popular examples include:
  - Spark on EKS
  - Karpenter on EKS Fargate
  - Transparent encryption with Wireguard and Cilium
  - Fully serverless cluster with EKS Fargate

## What Has Not

- Scaling and managing addons that are created through EKS Blueprints. With almost [1,200 projects on the CNCF roadmap](https://landscape.cncf.io/), the number of various ways and methods that a project allows for deploying onto a cluster (i.e. - Datadog offers 5 different Helm charts for its service, Prometheus hosts over 30 Helm charts for its services), as well as the number of different tools used to provision addons (i.e. - Terraform, ArgoCD, FluxCD, etc.), supporting both the number of addons and their different forms has been extremely challenging for the team. In addition to managing just the sheer number of addons, supporting the different configurations that users wish to have exposed in conjunction with testing and validating those various configurations is only compounded by the number of addons and their methods of creation.

- Managing resources provisioned on the cluster using Terraform. Terraform is a fantastic tool for provisioning infrastructure and it is the tool of choice for many customers when it comes to creating resources in AWS. However, there are a number of downsides with Terraform when it comes to provisioning resources on a Kubernetes cluster. These include:

  - Ordering of dependencies when relationships live outside of Terraform's HCL syntax. Terraform wants to evaluate the current state of what it controls and be able to plan a series of actions to align the current state with the desired state *in one action*. It does this once for each `terraform plan` or `terraform apply`, and if any issues are encountered, it simply fails and halts execution. When Terraform cannot infer the ordering of dependencies across resources (i.e. - through passing outputs of parent resources to arguments of child resources using the Terraform `<resource>.<name>.<attribute>` syntax), it will view this as no relationship between the resources and attempt to execute their provisioning in parallel and asynchronously. Any resources that are left waiting for a dependency will eventually timeout and fail, causing Terraform itself to timeout and fail the apply. This is where the reconciliation loop of a Kubernetes controller or operator on the cluster is better suited - continuously trying to reconcile the state over and over again as dependencies are eventually resolved. (To be clear - the issue of dependency ordering still exists, but the controller/operator will keep retrying and on each retry, some resources will succeed which will move the execution along with each cycle until everything is fully deployed. Terraform could do this if it kept re-trying, but it does not do this today)

  - Publicly exposing access to the EKS endpoints in order to provision resources defined outside of the VPC onto the cluster. When using Terraform, the resource provisioning operation is a "push" model where Terraform will send requests to the EKS API Server to create resources. Coupled with the fact that the Terraform operation typically resides outside of the VPC where the cluster is running, this results in users enabling public access to the EKS endpoints to provision resources. However, the more widely accepted approach by the Kubernetes community has been the adoption of GitOps which uses a "pull" based model, where an operator or controller running on the cluster will pull the resource definitions from a Git repository and reconcile state from within the cluster itself. This approach is more secure as it does not require public access to the EKS endpoints and instead relies on the cluster's internal network to communicate with the EKS API Server.

  - The nesting of multiple sub-modules in conjunction with the necessity to even require a module to be able to support an addon. When we compare and contrast the Terraform approach to addons versus the GitOps approach, the Terraform approach has a glaring disadvantage - the need to create a module that wraps the addon's Helm chart in order to provision the addon via Terraform. As opposed to the GitOps approach, where users simply consume the charts from where they are stored as needed. This creates a bottleneck on the team to review, test, and validate each new addon as well as the overhead then added for maintaining and updating those addons going forward. This also opens up more areas where breaking changes are encountered which is compounded by the fact that Terraform addons are grouped under an "umbrella" module which obfuscates versioning.

- Being able to support a combination of various tools, modules, frameworks, etc., to meet the needs of customers. The [`terraform-aws-eks`](https://github.com/terraform-aws-modules/terraform-aws-eks) was created long before EKS Blueprints, and many customers had already adopted this module for creating their clusters. In addition, Amazon has since adopted the [`eksctl`](https://github.com/weaveworks/eksctl) as the official CLI for Amazon EKS. When EKS Blueprints was first announced, many customers raised questions asking if they needed to abandon their current clusters created through those other tools in order to adopt EKS Blueprints. The answer is no - users can and should be able to use their existing clusters while EKS Blueprints can help augment that process through its supporting modules (addons, teams, etc.). This left the team with the question - why create a Terraform module for creating an EKS cluster when the [`terraform-aws-eks`](https://github.com/terraform-aws-modules/terraform-aws-eks) already exists and the EKS Blueprints implementation already uses that module for creating the control plane and security groups?

## What Is Changing

The direction for EKS Blueprints in v5 will shift from providing an all-encompassing, monolithic "framework" and instead focus more on how users can organize a set of modular components to create the desired solution on Amazon EKS. This will allow customers to use the components of their choosing in a way that is more familiar to them and their organization instead of having to adopt and conform to a framework.

With this shift in direction, the cluster definition will be removed from the project and instead examples will reference the [`terraform-aws-eks`](https://github.com/terraform-aws-modules/terraform-aws-eks) module for cluster creation. The remaining modules will be moved out to their own respective repositories as standalone projects. This leaves the EKS Blueprint project as the canonical place where users can receive guidance on how to configure their clusters to meet a desired architecture, how best to setup their clusters following well-architected practices, as well as references on the various ways that different workloads can be deployed on Amazon EKS.

### Notable Changes

1. EKS Blueprints will remove its Amazon EKS cluster Terraform module components (control plane, EKS managed node group, self-managed node group, and Fargate profile modules) from the project. In its place, users are encouraged to utilize the [`terraform-aws-eks`](https://github.com/terraform-aws-modules/terraform-aws-eks) module which meets or exceeds nearly all of the functionality of the EKS Blueprints v4.x cluster module. This includes the Terraform code contained at the root of the project as well as the `aws-eks-fargate-profiles`, `aws-eks-managed-node-groups`, `aws-eks-self-managed-node-groups`, and `launch-templates` modules which will all be removed from the project.
2. The `aws-kms` module will be removed entirely. This was consumed in the root project module for cluster secret encryption. In its place, users can utilize the KMS key creation functionality of the [`terraform-aws-eks`](https://github.com/terraform-aws-modules/terraform-aws-eks) module or the [`terraform-aws-kms`](https://github.com/terraform-aws-modules/terraform-aws-kms) module if they wish to control the key separately from the cluster itself.
3. The `emr-on-eks` module will be removed entirely; its replacement can be found in the new external module [`terraform-aws-emr`](https://github.com/terraform-aws-modules/terraform-aws-emr/tree/master/modules/serverless).
4. The `irsa` and `helm-addon` modules will be removed entirely; we have released a new external module [`terraform-aws-eks-blueprints-addon`](https://github.com/aws-ia/terraform-aws-eks-blueprints-addon) that is available on the Terraform registry that replicates/replaces the functionality of these two modules. This will now allow users, as well as partners, to create their own addons that are not natively supported by EKS Blueprints more easily and following the same process as EKS Blueprints.
5. The `aws-eks-teams` module will be removed entirely; its replacement will be the new external module [`terraform-aws-eks-blueprints-teams`](https://github.com/aws-ia/terraform-aws-eks-blueprints-teams) that incorporates the changes customers have been asking for in https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/842
6. The integration between Terraform and ArgoCD has been removed in the initial release of v5. The team is currently investigating better patterns and solutions in conjunction with the ArgoCD and FluxCD teams that will provide a better, more integrated experience when using a GitOps based approach for cluster management. This will be released in a future version of EKS Blueprints v5 and is tracked [here](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/issues/114)

### Resulting Project Structure

Previously under the v4.x structure, the EKS Blueprint project was comprised of various repositories across multiple AWS organizations that looked roughly like the following:

#### v4.x Structure

```
├── aws-ia/
|   ├── terraform-aws-eks-ack-addons/
|   └── terraform-aws-eks-blueprints/
|       ├── aws-auth-configmap.tf
|       ├── data.tf
|       ├── eks-worker.tf
|       ├── locals.tf
|       ├── main.tf
|       ├── outputs.tf
|       ├── variables.tf
|       ├── versions.tf
|       ├── examples/
|       └── modules
|           ├── aws-eks-fargate-profiles/
|           ├── aws-eks-managed-node-groups/
|           ├── aws-eks-self-managed-node-groups/
|           ├── aws-eks-teams/
|           ├── aws-kms/
|           ├── emr-on-eks/
|           ├── irsa/
|           ├── kubernetes-addons/
|           └── launch-templates/
├── awslabs/
|   ├── crossplane-on-eks/
|   └── data-on-eks/
└── aws-samples/
    ├── eks-blueprints-add-ons/   # Previously shared with the CDK based EKS Blueprints project
    └── eks-blueprints-workloads/ # Previously shared with the CDK based EKS Blueprints project
```

Under th new v5.x structure, the Terraform based EKS Blueprints project will be comprised of the following repositories:

#### v5.x Structure

```
├── aws-ia/
|   ├── terraform-aws-eks-ack-addons/
|   ├── terraform-aws-eks-blueprints/       # Will contain only example/blueprint implementations; no modules
|   ├── terraform-aws-eks-blueprints-addon  # Module for creating Terraform based addon (IRSA + Helm chart)
|   ├── terraform-aws-eks-blueprints-addons # Will contain a select set of addons supported by the EKS Blueprints
|   └── terraform-aws-eks-blueprints-teams  # Was previously `aws-eks-teams/` EKS Blueprint sub-module; updated based on customer feedback
└── awslabs/
    ├── crossplane-on-eks/
    └── data-on-eks/        # Data related patterns that used to be located in `terraform-aws-eks-blueprints/` are now located here
```

## What Can Users Expect

With these changes, the team intends to provide a better experience for users of the Terraform EKS Blueprints project as well as new and improved reference architectures. Following the v5 changes, the team intends to:

1. Improved quality of the examples provided - more information on the intent of the example, why it might be useful for users, what scenarios is the pattern applicable, etc. Where applicable, architectural diagrams and supporting material will be provided to highlight the intent of the example and how its constructed.
2. A more clear distinction between a blueprint and a usage reference. For example - the Karpenter on EKS Fargate blueprint should demonstrate all of the various aspects that users should be aware of and consider in order to take full advantage of this pattern (recommended practices, observability, logging, monitoring, security, day 2 operations, etc.); this is what makes it a blueprint. In contrast, a usage reference would be an example that shows how users can pass configuration values to the Karpenter provisioner. This example is less focused on the holistic architecture and more focused on how one might configure Karpenter using the implementation. The EKS Blueprints repository will focus mostly on holistic architecture and patterns, and any usage references should be saved for the repository that contains that implementation definition (i.e. - the `terraform-aws-eks-blueprints-addons` repository where the addon implementation is defined).
3. Faster, and more responsive feedback. The first part of this is going to be improved documentation on how to contribute which should help clarify whether a contribution is worthy and willing to be accepted by the team before any effort is spent by the contributor. However, the goal of v5 is to focus more on the value added benefits that EKS Blueprints was created to provide as opposed to simply mass producing Helm chart wrappers (addons) and trying to keep up with that operationally intensive process.
4. Lastly, more examples and blueprints that demonstrate various architectures and workloads that run on top of Amazon EKS as well as integrations into other AWS services.
