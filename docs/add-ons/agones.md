# Agones

[Agones](https://agones.dev/) is an open source platform for deploying, hosting, scaling, and orchestrating dedicated game servers for large scale multiplayer games on Kubernetes.

For complete project documentation, please visit the [Agones documentation site](https://agones.dev/site/docs/).

## Usage

Agones can be deployed by enabling the add-on via the following.

```hcl
enable_agones = true
```

You can optionally customize the Helm chart that deploys `Agones` via the following configuration.

*NOTE: Agones requires a Node group in Public Subnets and enable Public IP*

```hcl
  enable_agones = true
  # Optional  agones_helm_config
  agones_helm_config = {
    name                       = "agones"
    chart                      = "agones"
    repository                 = "https://agones.dev/chart/stable"
    version                    = "1.21.0"
    namespace                  = "agones-system" # Agones recommends to install in it's own namespace such as `agones-system` as shown here. You can specify any namespace other than `kube-system`
    values = [templatefile("${path.module}/helm_values/agones-values.yaml", {
      expose_udp            = true
      gameserver_namespaces = "{${join(",", ["default", "xbox-gameservers", "xbox-gameservers"])}}"
      gameserver_minport    = 7000
      gameserver_maxport    = 8000
    })]
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```
agones = {
  enable = true
}
```
