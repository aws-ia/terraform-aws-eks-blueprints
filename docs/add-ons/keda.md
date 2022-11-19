# KEDA

KEDA is a Kubernetes-based Event Driven Autoscaler. With KEDA, you can drive the scaling of any container in Kubernetes based on the number of events needing to be processed.

KEDA is a single-purpose and lightweight component that can be added into any Kubernetes cluster. KEDA works alongside standard Kubernetes components like the Horizontal Pod Autoscaler and can extend functionality without overwriting or duplication. With KEDA you can explicitly map the apps you want to use event-driven scale, with other apps continuing to function. This makes KEDA a flexible and safe option to run alongside any number of any other Kubernetes applications or frameworks..

[KEDA](https://github.com/kedacore/charts/tree/main/keda) chart bootstraps KEDA infrastructure on a Kubernetes cluster using the Helm package manager.

For complete project documentation, please visit the [KEDA documentation site](https://keda.sh/).

## Usage

KEDA can be deployed by enabling the add-on via the following.

```hcl
enable_keda = true
```

Deploy KEDA with custom `values.yaml`

```hcl
  # Optional Map value; pass keda-values.yaml from consumer module
  keda_helm_config = {
    name       = "keda"                                               # (Required) Release name.
    repository = "https://kedacore.github.io/charts"                  # (Optional) Repository URL where to locate the requested chart.
    chart      = "keda"                                               # (Required) Chart name to be installed.
    version    = "2.6.2"                                              # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/keda/locals.tf
    namespace  = "keda"                                               # (Optional) The namespace to install the release into.
    values = [templatefile("${path.module}/keda-values.yaml", {})]
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```
keda = {
  enable             = true
  serviceAccountName = "<service_account>"
}
```
