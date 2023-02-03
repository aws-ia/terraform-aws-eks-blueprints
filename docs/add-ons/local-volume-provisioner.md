# Local volume provisioner

[Local volume provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner) manages PersistentVolume lifecycle for pre-allocated disks by detecting and creating PVs for each local disk on the host, and cleaning up the disks when released


## Usage

Local volume provisioner can be deployed by enabling the add-on via the following.

```hcl
enable_local_volume_provisioner = true
```

Deploy Local volume provisioner with custom `values.yaml`

```hcl
  # Optional Map value; pass local-volume-provisioner-values.yaml from consumer module
   local_volume_provisioner_helm_config = {
    name       = "local-static-provisioner"                                            # (Required) Release name.
    namespace  = "local-static-provisioner"                                            # (Optional) The namespace to install the release into.
    values = [templatefile("${path.module}/local-volume-provisioner-values.yaml", {})]
  }
```
