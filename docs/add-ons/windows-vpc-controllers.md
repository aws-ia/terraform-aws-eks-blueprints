# Windows VPC Controllers

## Pre-requisites

[cert-manager](https://cert-manager.io/) is currently needed to enable Windows support. The `cert-manager` [Helm chart](../cert-manager) will be automatically enabeld, if Windows support is enabled.

### GitOps Configuration 

The following properties are made available for use when managing the add-on via GitOps 

```
windowsVpcController = {
  enable       = true
}
```