# Cilium

Cilium is open source software for transparently securing the network connectivity between application services deployed using Linux container management platforms like Docker and Kubernetes.

Cilium can be set up in two manners:
- In combination with the `Amazon VPC CNI plugin`. In this hybrid mode, the AWS VPC CNI plugin is responsible for setting up the virtual network devices as well as for IP address management (IPAM) via ENIs.
After the initial networking is setup for a given pod, the Cilium CNI plugin is called to attach eBPF programs to the network devices set up by the AWS VPC CNI plugin in order to enforce network policies, perform load-balancing and provide encryption.
Read the installation instruction [here](https://docs.cilium.io/en/latest/installation/cni-chaining-aws-cni/)
- As a replacement of `Amazon VPC CNI`,  read the complete installation guideline [here](https://docs.cilium.io/en/latest/installation/k8s-install-helm/)

For complete project documentation, please visit the [Cilium documentation site](https://docs.cilium.io/en/stable/).

## Usage

By Cilium in combination with the `Amazon VPC CNI plugin` by enabling the add-on via the following.

```hcl
enable_cilium = true
```

Deploy Cilium with custom `values.yaml`

```hcl
  # Optional Map value; pass cilium-values.yaml from consumer module
   cilium_helm_config = {
    name       = "cilium"                                               # (Required) Release name.
    repository = "https://helm.cilium.io/"                              # (Optional) Repository URL where to locate the requested chart.
    chart      = "cilium"                                               # (Required) Chart name to be installed.
    version    = "1.12.1"                                               # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/cilium/locals.tf
    values = [templatefile("${path.module}/cilium-values.yaml", {})]
  }
```

Refer to the [cilium default values file](https://github.com/cilium/cilium/blob/master/install/kubernetes/cilium/values.yaml) for complete values options for the chart


### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```hcl
cilium = {
  enable  = true
}
```
