# Crossplane
Crossplane is an open source Kubernetes add-on that enables platform teams to assemble infrastructure from multiple vendors, and expose higher level self-service APIs for application teams to consume, without having to write any code.

 - Crossplane is a control plane
 - Allow engineers to model their infrastructure as declarative configuration
 - Support managing a myriad of diverse infrastructure using "provider" plugins
 - It's an open source tool with strong communities

For complete project documentation, please visit the [Crossplane](https://crossplane.io/).

## Usage

### Crossplane Deployment

Crossplane can be deployed by enabling the add-on via the following. Check out the full [example](modules/kubernetes-addons/crossplane/locals.tf) to deploy the EKS Cluster with Crossplane.

```hcl
  enable_crossplane = true
```

You can optionally customize the Helm chart that deploys `Crossplane` via the following configuration.

```hcl
  enable_crossplane = true

  crossplane_helm_config = {
    name                      = "crossplane"
    chart                     = "crossplane"
    repository                = "https://charts.crossplane.io/stable/"
    version                   = "1.6.2"
    namespace                 = "crossplane-system"
    values = [templatefile("${path.module}/values.yaml", {
         service_account_name = var.service_account_name,
         operating_system     = "linux"
    })]
  }

  crossplane_irsa_policies = [] # Optional to add additional policies to Crossplane IRSA
```

### Crossplane AWS Provider Deployment
AWS Provider for Crossplane gets deployed by default when you enable `enable_crossplane = true`.
The below configuration helps you to upgrade the AWS provider version and lets you define custom IAM policies to manage AWS resources through IRSA.

Crossplane requires Admin like permissions to create and update resources similar to Terraform deploy role.

Please find more details from [AWS Provider](https://github.com/crossplane/provider-aws)

```hcl
  crossplane_provider_aws = {
    provider_aws_version = "v0.23.0"
    additional_irsa_policies = ["<ENTER_YOUR_IAM_POLICY>"]
  }
```

Checkout the full [example](examples/crossplane) to deploy Crossplane with `kubernetes-addons` module

### GitOps Configuration
The following properties made available for use when managing the add-on via GitOps.

Refer to [locals.tf](modules/kubernetes-addons/crossplane/locals.tf) for latest config. GitOps with ArgoCD Add-on repo is located [here](https://github.com/aws-samples/ssp-eks-add-ons/blob/main/chart/values.yaml)

```hcl
  argocd_gitops_config = {
    enable             = true
  }
```
