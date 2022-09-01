# Cilium

Cilium is open source software for transparently securing the network connectivity between application services deployed using Linux container management platforms like Docker and Kubernetes.

Cilium can be set up in two manners:
- In combination with the `Amazon VPC CNI plugin`. In this hybrid mode, the AWS VPC CNI plugin is responsible for setting up the virtual network devices as well as for IP address management (IPAM) via ENIs.
After the initial networking is setup for a given pod, the Cilium CNI plugin is called to attach eBPF programs to the network devices set up by the AWS VPC CNI plugin in order to enforce network policies, perform load-balancing and provide encryption.
Read the installation instruction [here](https://docs.cilium.io/en/stable/gettingstarted/cni-chaining-aws-cni/#chaining-aws-cni)
- As a replacement of `Amazon VPC CNI`,  read the complete installation guideline [here](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-helm/)

For complete project documentation, please visit the [Cilium documentation site](https://docs.cilium.io/en/stable/).

## Usage

### Cilium in combination with the Amazon VPC CNI plugin
Cilium can be deployed in combination with the `Amazon VPC CNI plugin` by enabling the add-on via the following.

```hcl
enable_cilium = true
```

### Cilium as a replacement of Amazon VPC CNI
If you aim to install cilium as a replacement of `Amazon VPC CNI` for default CNI in your cluster, below is the configuration.
```hcl
  enable_cilium = true
  cilium_helm_config = {
    default_cni = true  
 }
```
Refer to the additional required steps in the [Cilium as a replacement of Amazon VPC CNI](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-helm/) to complete the installation


### Custom helm chart configuration
You can optionally customize the Helm chart that deploys `cilium` via the following configuration.

```hcl
  cilium_helm_config = {
    name                       = "cilium"                        # (Required) Release name.
    chart                      = "cilium"                        # (Required) Chart name to be installed
    repository                 = "https://helm.cilium.io/"       # (Optional) Repository URL where to locate the requested chart.
    version                    = "1.12.1"                        # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/cilium/locals.tf
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```hcl
cilium = {
  enable  = true
}
```
