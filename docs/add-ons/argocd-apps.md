# ArgoCD Apps

[ArgoCD Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) is a companion tool for ArgoCD. With this tool, you can easily set up a connection between ArgoCD and the git repository that contains those manifests or helm charts that ArgoCD should install on a kubernetes cluster


## Usage

ArgoCD apps can be deployed by enabling the add-on via the following.

```hcl
enable_argocd_apps = true
```



### Customizing the Helm Chart

You can customize the Helm chart that deploys `ArgoCD Apps` via the following configuration:

```hcl
 argocd_apps_helm_config = {
    repository = var.chart_repository
    version    = var.chart_version
    values     = [file("values.yaml")]
  }
```
