# ArgoCD

[ArgoCD](https://argo-cd.readthedocs.io/en/stable/) Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

Application definitions, configurations, and environments should be declarative and version controlled. Application deployment and lifecycle management should be automated, auditable, and easy to understand.
## Usage

ArgoCD can be deployed by enabling the add-on via the following.

```hcl
  #---------------------------------------
  # ENABLE ARGOCD
  #---------------------------------------
  argocd_enable = true

  # Optional Map value - Override values.yaml for Argo CD
  argocd_helm_chart = {
    name             = "argo-cd"
    chart            = "argo-cd"
    repository       = "https://argoproj.github.io/argo-helm"
    version          = "3.26.3"
    namespace        = "argocd"
    timeout          = "1200"
    create_namespace = true
    values = [templatefile("${path.module}/argocd-values.yaml", {})]
  }
```
