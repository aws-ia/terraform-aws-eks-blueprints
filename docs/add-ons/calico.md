# Calico

Calico is a widely adopted, battle-tested open source networking and network security solution for Kubernetes, virtual machines, and bare-metal workloads
Calico provides two major services for Cloud Native applications: network connectivity between workloads and network security policy enforcement between workloads.
[Calico](https://projectcalico.docs.tigera.io/getting-started/kubernetes/helm#download-the-helm-chart) docs chart bootstraps Calico infrastructure on a Kubernetes cluster using the Helm package manager.

For complete project documentation, please visit the [Calico documentation site](https://www.tigera.io/calico-documentation/).

## Usage

Calico can be deployed by enabling the add-on via the following.

```hcl
enable_calico = true
```

Deploy Calico with custom `values.yaml`

```hcl
  # Optional Map value; pass calico-values.yaml from consumer module
   calico_helm_config = {
    name       = "calico"                                               # (Required) Release name.
    repository = "https://docs.projectcalico.org/charts"                # (Optional) Repository URL where to locate the requested chart.
    chart      = "tigera-operator"                                      # (Required) Chart name to be installed.
    version    = "v3.24.1"                                              # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/calico/locals.tf
    namespace  = "tigera-operator"                                      # (Optional) The namespace to install the release into.
    values = [templatefile("${path.module}/calico-values.yaml", {})]
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```sh
calico = {
  enable  = true
}
```
