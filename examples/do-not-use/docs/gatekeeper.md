# Gatekeeper

Gatekeeper is an admission controller that validates requests to create and update Pods on Kubernetes clusters, using the Open Policy Agent (OPA). Using Gatekeeper allows administrators to define policies with a constraint, which is a set of conditions that permit or deny deployment behaviors in Kubernetes.

For complete project documentation, please visit the [Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/).
For reference templates refer [Templates](https://github.com/open-policy-agent/gatekeeper/tree/master/charts/gatekeeper/templates)

## Usage

Gatekeeper can be deployed by enabling the add-on via the following.

```hcl
enable_gatekeeper = true
```

You can also customize the Helm chart that deploys `gatekeeper` via the following configuration:

```hcl
  enable_gatekeeper = true

  gatekeeper = {
    name          = "gatekeeper"
    chart_version = "3.12.0"
    repository    = "https://open-policy-agent.github.io/gatekeeper/charts"
    namespace     = "gatekeeper-system"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }
```
