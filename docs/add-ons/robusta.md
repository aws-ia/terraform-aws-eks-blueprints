# Robusta

Robusta is an open source platform for Kubernetes troubleshooting. It sits on top of your monitoring stack (Prometheus, Elasticsearch, etc.) and tells you why alerts occurred and how to fix them.

Robusta has three main parts, all open source:
- An automations engine for Kubernetes
- Builtin automations to enrich and fix common alerts
- Manual troubleshooting tools for everything else

For complete project documentation, please visit the [Robusta documentation site](https://docs.robusta.dev/master/index.html).

## Usage

Robusta can be deployed by enabling the add-on via the following.

```hcl
enable_robusta = true
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```hcl
robusta = {
  enable = true
}
```
