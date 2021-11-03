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
```

You can optionally customize the Helm chart that deploys ArgoCD via the following configuration. 

```hcl
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

### Boostrapping 

The framework provides an approach to bootstraping workloads and/or additional add-ons by leveraging the ArgoCD [App of Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) pattern. 

 The following code example demonstrates how you can supply information for a repository in order to bootstrap multiple workloads in a new EKS cluster. The example leverages a [sample App of Apps repository](https://github.com/aws-samples/ssp-eks-workloads.git) that ships with the EKS SSP solution.

```hcl
argocd_applications = {
  workloads = {
    namespace         = "argocd"
    repo_path         = "envs/dev"
    repo_url          = "https://github.com/aws-samples/ssp-eks-workloads.git"
    target_revision   = "HEAD"
    destination       = "https://kubernetes.default.svc"
    project           = "default"
    values            = {}
  }
}
```