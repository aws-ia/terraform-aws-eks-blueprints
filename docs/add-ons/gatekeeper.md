# Gatekeeper

Gatekeeper is an admission controller that validates requests to create and update Pods on Kubernetes clusters, using the Open Policy Agent (OPA). Using Gatekeeper allows administrators to define policies with a constraint, which is a set of conditions that permit or deny deployment behaviors in Kubernetes.

For complete project documentation, please visit the [Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/).
For reference templates refer [Templates](https://github.com/open-policy-agent/gatekeeper/tree/master/charts/gatekeeper/templates)

## Usage

Gatekeeper can be deployed by enabling the add-on via the following.

```hcl
enable_gatekeeper = true
```

You can optionally customize the Helm chart that deploys `Gatekeeper` via the following configuration.

```hcl
  enable_gatekeeper = true
  # Optional  gatekeeper_helm_config
  gatekeeper_helm_config = {
    name                       = "gatekeeper"
    chart                      = "gatekeeper"
    repository                 = "https://open-policy-agent.github.io/gatekeeper/charts"
    version                    = "3.9.0"
    namespace                  = "gatekeeper-system"
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

```hcl
  argocd_gitops_config = {
    enable                    = true
    serviceAccountName        = local.service_account_name
    controllerClusterName     = var.eks_cluster_id
    controllerClusterEndpoint = local.eks_cluster_endpoint
    awsDefaultInstanceProfile = var.node_iam_instance_profile
  }
```
