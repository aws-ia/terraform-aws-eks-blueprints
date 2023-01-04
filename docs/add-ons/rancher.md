# Rancher

Rancher is a complete software stack for teams adopting containers. It addresses the operational and security challenges of managing multiple Kubernetes clusters, while providing DevOps teams with integrated tools for running containerized workloads.

[Rancher](https://github.com/rancher/rancher/tree/release/v2.7/chart) chart bootstraps Rancher infrastructure on a Kubernetes cluster using the Helm package manager.

For complete project documentation, please visit the [Rancher documentation site](https://ranchermanager.docs.rancher.com/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster).

## Usage

Rancher can be deployed by enabling the add-on via the following.

```hcl
enable_rancher = true
```

### Customizing the Helm Chart

You can customize the Helm chart that deploys `Rancher` via the following configuration:

```hcl
rancher_helm_config       = {
    hostname                  = "${var.rancher_host_name}"
    bootstrapPassword         = "admin"
    ingress_tls_source        = "letsEncrypt"
    ingress_ingressClassName  = "nginx"
    version                   = "2.7.0"
  }
```
