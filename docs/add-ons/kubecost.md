# Kubecost

Kubecost provides real-time cost visibility and insights for teams using Kubernetes, helping you continuously reduce your cloud costs.
Amazon EKS supports Kubecost, which you can use to monitor your costs broken down by Kubernetes resources including pods, nodes, namespaces, and labels.
[Cost monitoring](https://docs.aws.amazon.com/eks/latest/userguide/cost-monitoring.html) docs provides steps to bootstrap Kubecost infrastructure on a EKS cluster using the Helm package manager.

For complete project documentation, please visit the [Kubecost documentation site](https://www.kubecost.com/).

Note: If your cluster is version 1.23 or later, you must have the [Amazon EBS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) installed on your cluster.

## Usage

Kubecost can be deployed by enabling the add-on via the following.

```hcl
enable_kubecost = true
```

Deploy Kubecost with custom `values.yaml`

```hcl
  # Optional Map value; pass kubecost-values.yaml from consumer module
    kubecost_helm_config = {
    name       = "kubecost"                                             # (Required) Release name.
    repository = "oci://public.ecr.aws/kubecost"                        # (Optional) Repository URL where to locate the requested chart.
    chart      = "cost-analyzer"                                        # (Required) Chart name to be installed.
    version    = "1.96.0"                                               # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/kubecost/locals.tf
    namespace  = "kubecost"                                             # (Optional) The namespace to install the release into.
    values = [templatefile("${path.module}/kubecost-values.yaml", {})]
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```sh
kubecost = {
  enable  = true
}
```
