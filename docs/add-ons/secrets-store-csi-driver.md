# secrets-store-csi-driver

Secrets Store CSI Driver for Kubernetes secrets - Integrates secrets stores with Kubernetes via a [Container Storage Interface (CSI)](https://kubernetes-csi.github.io/docs/) volume.

The Secrets Store CSI Driver `secrets-store.csi.k8s.io` allows Kubernetes to mount multiple secrets, keys, and certs stored in enterprise-grade external secrets stores into their pods as a volume. Once the Volume is attached, the data in it is mounted into the container’s file system.

For more details, refer [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/)

## Usage

secrets-store-csi-driver can be deployed by enabling the add-ons via the following.

```hcl
enable_secrets_store_csi_driver = true
```

You can optionally customize the Helm chart that deploys `secrets_store_csi_driver` via the following configuration.

```hcl
secrets_store_csi_driver_helm_config = {
    name       = "secrets-store-csi-driver"
    chart      = "secrets-store-csi-driver"
    repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
    version    = "1.2.4"
    namespace  = "secrets-store-csi-driver"
    set_values = [
      {
        name  = "syncSecret.enabled"
        value = "false"
      },
      {
        name  = "enableSecretRotation"
        value = "false"
      }
    ]
}
```
