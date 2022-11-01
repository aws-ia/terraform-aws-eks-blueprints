# Istio

[Istio](https://istio.io/) is an open source service mesh that layers transparently onto existing distributed applications. Istio’s powerful features provide a uniform and more efficient way to secure, connect, and monitor services.

For complete project documentation, please visit the [Istio documentation site](https://istio.io/latest/docs/).

## Usage

Istio can be deployed by enabling the add-on via the following: 

```hcl
enable_istio = true
```

# Optional, choose the Istio modules to be installed

```hcl
istio_version                = "1.15.2"
install_istio_base           = "true"
install_istio_cni            = "true"
install_istiod               = "true"
install_istio_ingressgateway = "true"
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```hcl
istio = {
  enable  = true
}
```
