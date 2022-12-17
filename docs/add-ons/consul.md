# Consul

HashiCorp Consul is a service networking solution that enables teams to manage secure network connectivity between services and across on-prem and multi-cloud environments and runtimes. Consul offers service discovery, service mesh, traffic management, and automated updates to network infrastructure device.

For complete project documentation, please visit the [consul](https://developer.hashicorp.com/consul/docs/k8s/installation/install).

## Usage

Consul can be deployed by enabling the add-on via the following.

```hcl
enable_consul = true
```

You can optionally customize the Helm chart via the following configuration.

```hcl
  enable_consul = true
  # Optional consul_helm_config
  consul_helm_config = {
    name                       = "consul"
    chart                      = "consul"
    repository                 = "https://helm.releases.hashicorp.com"
    version                    = "1.0.1"
    namespace                  = "consul"
    values = [templatefile("${path.module}/values.yaml", {
      ...
    })]
  }
```

### GitOps Configuration
The following properties are made available for use when managing the add-on via GitOps.

GitOps with ArgoCD Add-on repo is located [here](https://github.com/aws-samples/eks-blueprints-add-ons/blob/main/chart/values.yaml)

```hcl
  consul = {
    enable = true
  }
```
