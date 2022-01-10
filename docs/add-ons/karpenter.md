# Karpenter

Karpenter is an open-source node provisioning project built for Kubernetes. Karpenter automatically launches just the right compute resources to handle your cluster's applications. It is designed to let you take full advantage of the cloud with fast and simple compute provisioning for Kubernetes clusters.

For complete project documentation, please visit the [Karpenter](https://karpenter.sh/docs/getting-started/).

## Usage

Karpenter can be deployed by enabling the add-on via the following.

```hcl
enable_karpenter = true
```

You can optionally customize the Helm chart that deploys `Karpenter` via the following configuration.

```hcl
  enable_karpenter = true
  # Optional  agones_helm_config
  karpenter_helm_config = {
    name                       = "karpenter"
    chart                      = "karpenter"
    repository                 = "https://charts.karpenter.sh"
    version                    = "0.5.4"
    namespace                  = "karpenter"
    values = [templatefile("${path.module}/values.yaml", {
         eks_cluster_id       = var.eks_cluster_id,
         eks_cluster_endpoint = var.eks_cluster_endpoint,
         service_account_name = var.service_account_name,
         operating_system     = "linux"
    })]
  }
```

### GitOps Configuration
The following properties are made available for use when managing the add-on via GitOps.

```
  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account_name
    clusterName        = var.eks_cluster_id
    clusterEndpoint    = local.eks_cluster_endpoint
  }
```
