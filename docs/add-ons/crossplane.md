# Crossplane
Crossplane is an open source Kubernetes add-on that enables platform teams to assemble infrastructure from multiple vendors, and expose higher level self-service APIs for application teams to consume, without having to write any code.

 - Crossplane is a control plane
 - Allow engineers to model their infrastructure as declarative configuration
 - Support managing a myriad of diverse infrastructure using "provider" plugins
 - It's an open source tool with strong communities

For complete project documentation, please visit the [Crossplane](https://crossplane.io/).

## Usage

### Crossplane Deployment

Crossplane can be deployed by enabling the add-on via the following. Check out the full [example](https://github.com/awslabs/crossplane-on-eks/tree/main/bootstrap/terraform) to deploy the EKS Cluster with Crossplane.

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
    version                   = "1.10.1" # Get the lates version from https://github.com/crossplane/crossplane
    namespace                 = "crossplane-system"
  }
```

To install the [Upbound Universal Crossplane (UXP) helm chart](https://github.com/upbound/universal-crossplane/tree/main/cluster/charts/universal-crossplane) use the following configuration.

```hcl
  enable_crossplane = true #defaults to Upstream Crossplane Helm Chart

  crossplane_helm_config = {
    name        = "crossplane"
    chart       = "universal-crossplane"
    repository  = "https://charts.upbound.io/stable/"
    version     = "1.10.1" # Get the latest version from https://github.com/upbound/universal-crossplane
    namespace   = "upbound-system"
    description = "Upbound Universal Crossplane (UXP)"
  }
```


### Crossplane Providers Deployment
This module provides options to deploy the following providers for Crossplane. These providers disabled by default, and it can be enabled using the config below.

 - [AWS Provider](https://github.com/crossplane/provider-aws)
 - [Upbound AWS Provider](https://github.com/upbound/provider-aws)
 - [Kubernetes Provider](https://github.com/crossplane-contrib/provider-kubernetes)
 - [Helm Provider](https://github.com/crossplane-contrib/provider-helm)
 - [Terrajet AWS Provider](https://github.com/crossplane-contrib/provider-jet-aws)

_NOTE: Crossplane requires Admin like permissions to create and update resources similar to Terraform deploy role.
This example config uses AdministratorAccess, but you should select a policy with the minimum permissions required to provision your resources._

Config to deploy [AWS Provider](https://github.com/crossplane/provider-aws)
```hcl
# Creates ProviderConfig -> aws-provider
crossplane_aws_provider = {
  enable                   = true
}
```

Config to deploy [Upbound AWS Provider](https://github.com/upbound/provider-aws)
```hcl
# Creates ProviderConfig -> upbound-aws-provider
crossplane_upbound_aws_provider = {
  enable                   = true
}
```

Config to deploy [Terrajet AWS Provider (Deprecated)](https://github.com/crossplane-contrib/provider-jet-aws)
```hcl
# Creates ProviderConfig -> jet-aws-provider
crossplane_jet_aws_provider = {
  enable                   = true
  provider_aws_version     = "v0.4.1"  # Get the latest version from  https://github.com/crossplane-contrib/provider-jet-aws
  additional_irsa_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}
```

_NOTE: Crossplane requires cluster-admin permissions to create and update Kubernetes resources._

Config to deploy [Kubernetes provider](https://github.com/crossplane-contrib/provider-kubernetes)
```hcl
# Creates ProviderConfig -> kubernetes-provider
crossplane_kubernetes_provider = {
  enable                   = true
}
```

Config to deploy [Helm Provider](https://github.com/crossplane-contrib/provider-helm)
```hcl
# Creates ProviderConfig -> helm-provider
crossplane_helm_provider = {
  enable                   = true
}
```
