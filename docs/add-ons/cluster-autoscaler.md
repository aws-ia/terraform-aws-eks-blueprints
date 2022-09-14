# Cluster Autoscaler

Cluster Autoscaler is a tool that automatically adjusts the number of nodes in your cluster when:

* Pods fail due to insufficient resources, or
* Pods are rescheduled onto other nodes due to being in nodes that are underutilized for an extended period of time.

The [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) add-on adds support for Cluster Autoscaler to an EKS cluster. It is typically installed as a **Deployment** in your cluster. It uses leader election to ensure high availability, but scaling is one done via one replica at a time.

## Usage

[Cluster Autoscaler](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/cluster-autoscaler) can be deployed by enabling the add-on via the following.

```hcl
enable_cluster_autoscaler = true
```
Deploy Cluster autoscaler with custom `values.yaml`

```hcl
  # Optional Map value; pass cluster-autoscaler-values.yaml from consumer module
   cilium_helm_config = {
    name       = "cluster-autoscaler"                                               # (Required) Release name.
    repository = "https://kubernetes.github.io/autoscaler"                          # (Optional) Repository URL where to locate the requested chart.
    chart      = "cluster-autoscaler"                                               # (Required) Chart name to be installed.
    version    = "9.19.1"                                                           # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/cilium/locals.tf
    values = [templatefile("${path.module}/cluster-autoscaler-values.yaml", {}),    # (Optional) Pass one or multiple values to the chart using terraform yaml related functions
              file("cluster-autoscaler-custom-values.yaml"),
              templatefile("cluster-autoscaler-additional.yaml", {}),
              yamlencode({"awsRegion": "us-east-1"})
    ]  
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```
clusterAutoscaler = {
  enable = true
}
```
