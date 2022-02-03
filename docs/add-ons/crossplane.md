# Crossplane
Crossplane is an open source Kubernetes add-on that enables platform teams to assemble infrastructure from multiple vendors, and expose higher level self-service APIs for application teams to consume, without having to write any code.

 - Crossplane is a control plane
 - Allow engineers to model their infrastructure as declarative configuration
 - Support managing a myriad of diverse infrastructure using "provider" plugins
 - It's an open source tool with strong communities

For complete project documentation, please visit the [Crossplane](https://crossplane.io/)

## Usage

Crossplane can be deployed by enabling the add-on via the following.

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

Here is a full example to consume `kubernetes-addons` module and deploy Crossplane

```hcl

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_id
}
# Very important to authenticate with Kubernetes Server
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
# Helm provider to deploy Crossplane Add-on
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}
# This example is showing one add-on however you can add other add-ons to this module block
module "kubernetes-addons" {
  source         = "github/aws-samples/aws-eks-accelerator-for-terraform//modules/kubernetes-addons"
  eks_cluster_id = var.eks_cluster_id
  tags           = var.tags

  enable_crossplane = true
  crossplane_helm_config = {
    name                   = "crossplane"
    chart                  = "crossplane"
    repository             = "https://charts.crossplane.io/stable/"
    version                = "1.6.2"
    namespace              = "crossplane-system"
    values = [templatefile("${path.module}/values.yaml", {
      service_account_name = var.service_account_name,
      operating_system     = "linux"
    })]
  }
  crossplane_irsa_policies = [] # Optional to add additional policies to Crossplane IRSA
}
```

### GitOps Configuration
The following properties made available for use when managing the add-on via GitOps.

```
  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
  }
```
