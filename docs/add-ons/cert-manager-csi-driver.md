# cert-manager-csi-driver

Cert Manager csi-driver is a Container Storage Interface (CSI) driver plugin for Kubernetes to work along cert-manager. The goal for this plugin is to seamlessly request and mount certificate key pairs to pods. This is useful for facilitating mTLS, or otherwise securing connections of pods with guaranteed present certificates whilst having all of the features that cert-manager provides.

For complete project documentation, please visit the [cert-manager-csi-driver documentation site](https://cert-manager.io/docs/projects/csi-driver).

## Usage

cert-manger can be deployed by enabling the add-on via the following.

```hcl
enable_cert_manager_csi_driver = true
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```

certManagerCsiDriver = {
  enable = true
}
```
