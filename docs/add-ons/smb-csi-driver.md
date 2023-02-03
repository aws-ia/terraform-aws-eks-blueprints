# SMB CSI Driver Helm Chart
SMB CSI Driver allows Kubernetes to access SMB server on both Linux and Windows nodes.
The driver requires existing and already configured SMB server, it supports dynamic provisioning of Persistent Volumes via Persistent Volume Claims by creating a new subdirectory under SMB server.

[SMB CSI Driver](https://github.com/kubernetes-csi/csi-driver-smb/tree/master/charts) docs chart bootstraps SMB CSI Driver infrastructure on a Kubernetes cluster using the Helm package manager.

For complete project documentation, please visit the [SMB CSI Driver documentation site](https://github.com/kubernetes-csi/csi-driver-smb).

## Usage

SMB CSI Driver can be deployed by enabling the add-on via the following.

```hcl
enable_smb_csi_driver = true
```

Deploy SMB CSI Driver with custom `values.yaml`

```hcl
  # Optional Map value; pass smb-csi-driver-values.yaml from consumer module
   smb_csi_driver_helm_config = {
    name       = "csi-driver-smb"                                                                          # (Required) Release name.
    repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts"           # (Optional) Repository URL where to locate the requested chart.
    chart      = "csi-driver-smb"                                                                          # (Required) Chart name to be installed.
    version    = "v1.9.0"                                                                                  # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/smb-csi-driver/locals.tf
    values     = [templatefile("${path.module}/smb-csi-driver-values.yaml", {})]
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```sh
smbCsiDriver = {
  enable  = true
}
```
