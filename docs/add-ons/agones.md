# Agones

[Agones](https://agones.dev/) is an open source platform for deploying, hosting, scaling, and orchestrating dedicated game servers for large scale multiplayer games on Kubernetes.

For complete project documentation, please visit the [Agones documentation site](https://agones.dev/site/docs/).

## Usage

Agones can be deployed by enabling the add-on via the following.

```hcl
agones_enable = true
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```
agones = {
  enable = true
}
```
