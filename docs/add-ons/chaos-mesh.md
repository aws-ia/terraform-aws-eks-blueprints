# Chaos Mesh

Chaos Mesh is an open source cloud-native Chaos Engineering platform. It offers various types of fault simulation and has an enormous capability to orchestrate fault scenarios

[Chaos Mesh](https://chaos-mesh.org/docs/production-installation-using-helm/) docs chart bootstraps Chaos Mesh infrastructure on a Kubernetes cluster using the Helm package manager.

For complete project documentation, please visit the [Chaos Mesh site](https://chaos-mesh.org/docs/).

## Usage

Chaos Mesh can be deployed by enabling the add-on via the following.

```hcl
enable_chaos_mesh = true
```

Deploy Chaos Mesh with custom `values.yaml`

```hcl
  # Optional Map value; pass chaos-mesh-values.yaml from consumer module
   chaos_mesh_helm_config = {
    name       = "chaos-mesh"                                               # (Required) Release name.
    repository = "https://charts.chaos-mesh.org"                            # (Optional) Repository URL where to locate the requested chart.
    chart      = "chaos-mesh"                                               # (Required) Chart name to be installed.
    version    = "2.3.0"                                                    # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/chaos-mesh/locals.tf
    namespace  = "chaos-testing"                                            # (Optional) The namespace to install the release into.
    values = [templatefile("${path.module}/chaos-mesh-values.yaml", {})]
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```sh
chaosMesh = {
  enable  = true
}
```
