# cert-manager

cert-manager adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates.

For complete project documentation, please visit the [cert-manager documentation site](https://cert-manager.io/docs/).

## Usage

cert-manger can be deployed by enabling the add-on via the following.

```hcl
cert_manager_enable = true
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```
certManager = {
  enable = true
}
```
