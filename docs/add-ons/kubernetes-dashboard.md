# Kubernetes Dashboard

[Kubernetes Dashboard](https://github.com/kubernetes/dashboard) is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage applications running in the cluster and troubleshoot them, as well as manage the cluster itself.

## Usage

The following will deploy the Kubernetes Dashboard into an EKS Cluster.

```hcl-terraform
enable_kubernetes_dashboard = true
```

Enable Kubernetes Dashboard with custom `values.yaml`

```hcl-terraform
  enable_kubernetes_dashboard = true

  # Optional Map value
  kubernetes_dashboard_helm_config = {
    name       = "kubernetes-dashboard" # (Required) Release name.
    repository = "https://kubernetes.github.io/dashboard/" # (Optional) Repository URL where to locate the requested chart.
    chart      = "kubernetes-dashboard" # (Required) Chart name to be installed.
    version    = "5.2.0"
    namespace  = "kube-system"
    values = [templatefile("${path.module}/values.yaml", {})]
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```hcl-terraform
argocd_gitops_config = {
  enable             = true
  serviceAccountName = local.service_account
}
```

### Connecting to the Dashboard

Follow the steps outlined [here](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html#view-dashboard) to connect to the dashboard
