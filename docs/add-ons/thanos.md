# Thanos

Thanos is a highly available metrics system that can be added on top of existing Prometheus deployments, providing a global query view across all Prometheus installations.

For complete project documentation, please visit the [Thanos documentation site](https://thanos.io/tip/thanos/getting-started.md/).

## Usage

[Thanos](https://github.com/bitnami/charts/tree/main/bitnami/thanos) can be deployed by enabling the add-on via the following.

```hcl
enable_thanos = true
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```
thanos = {
  enable = true
}
```
