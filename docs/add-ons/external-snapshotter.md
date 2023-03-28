
# External Snapshotter

[CSI Snapshotter](https://github.com/kubernetes-csi/external-snapshotter) is a Kubernetes controller that handles snapshoting of external volumes. It is part of Kubernetes implementation of [Container Storage Interface (CSI)](https://github.com/container-storage-interface/spec).

## Usage

The External Snapshotter can be deployed by enabling the add-on via the following.

```hcl
enable_external_snapshotter = true
```

You can optionally customize the Helm chart that deploys the operator via the following configuration.

```hcl
  enable_external_snapshotter = true
  external_snapshotter_helm_config = {
    name                       = "external-snapshotter"
    chart                      = "${path.module}/snapshot-controller"
    version                    = "0.0.1"
    namespace                  = "kube-system"
  }
```
