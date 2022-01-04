# ArgoCD

[ArgoCD](https://argo-cd.readthedocs.io/en/stable/) Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

Application definitions, configurations, and environments should be declarative and version controlled. Application deployment and lifecycle management should be automated, auditable, and easy to understand.

## Usage

ArgoCD can be deployed by enabling the add-on via the following.

```hcl
enable_argocd = true
```

### Admin Password 

ArgoCD has a built in `admin` user that has full access to the ArgoCD instance. By default, Argo will create a password for the admin user. 

You can optionally configure a custom password for the admin user by specifying the name of an AWS Secrets Manager secret. The value for the secret will be stored as a Kubernetes Secret and used as the admin password. 

```
argocd_admin_password_secret_name = <secret_name>
```

See the [ArgoCD documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/) for additional details on managing users.

### Customizing the Helm Chart 

You can customize the Helm chart that deploys `ArgoCD` via the following configuration:

```hcl
argocd_helm_config = {
  name             = "argo-cd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "3.29.5"
  namespace        = "argocd"
  timeout          = "1200"
  create_namespace = true
  values = [templatefile("${path.module}/argocd-values.yaml", {})]
}
```

### Boostrapping

The framework provides an approach to bootstrapping workloads and/or additional add-ons by leveraging the ArgoCD [App of Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) pattern.

The following code example demonstrates how you can supply information for a repository in order to bootstrap multiple workloads in a new EKS cluster. The example leverages a [sample App of Apps repository](https://github.com/aws-samples/ssp-eks-workloads.git) that ships with the EKS SSP solution.

```hcl
argocd_applications = {
  workloads = {
    namespace           = "argocd"
    path                = "envs/dev"
    repo_url            = "https://github.com/aws-samples/ssp-eks-workloads.git"
    target_revision     = "HEAD"
    destination         = "https://kubernetes.default.svc"
    project             = "default"
    ssh_key_secret_name = "github-ssh-key"  # Needed for private repos
    add_on_application  = false             # Indicates the root add-on application.
    values              = {}
  }
}
```

The value for the `ssh_key_secret_name` should be the name of a secret in AWS Secrets Manager. The value for the secret should be a private SSH Key.

### Add-ons

A common operational pattern is to leverage Infrastructure as Code for provisioning EKS clusters (in addition to other AWS resources) and GitOps for managing cluster configuration. The framework provides support for this approach by leveraging the ArgoCD [App of Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) pattern.

To configure the framework to leverage ArgoCD for managing add-ons, you must pass configuration for a root ArgoCD Application that points to your desired add-ons. You can specify the root application by setting the `add_on_application` value to true in your application configuration.

Additionally, you must set the `argocd_manage_add_ons` property to true. When this flag is set, the framework will still provision all AWS resources necessary to support add-on functionality, but it will not apply Helm charts directly via Terraform. Instead, the framework will pass AWS resource values needed for each add-on to ArgoCD via the values map of the root add-on Application. For specific values passed for each add-on, see the individual add-on documentation.

Sample configuration can be found below:

```
enable_argocd           = true
argocd_manage_add_ons   = true
argocd_applications     = {
  infra = {
    namespace           = "argocd"
    path                = "<path>"
    repo_url            = "<repo_url>"
    target_revision     = "HEAD"
    destination         = "https://kubernetes.default.svc"
    project             = "default"
    ssh_key_secret_name = "github-ssh-key"  # Needed for private repos
    add_on_application  = true              # Indicates the root add-on application.
    values              = {}
  }
}
```

### Complete Example 

The following demonstrates a complete example for configuring ArgoCD. 

```
enable_argocd                       = true
argocd_manage_add_ons               = true
argocd_admin_password_secret_name   = <secret_name>

argocd_helm_config = {
  name             = "argo-cd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "3.29.5"
  namespace        = "argocd"
  timeout          = "1200"
  create_namespace = true
  values = [templatefile("${path.module}/argocd-values.yaml", {})]
}

argocd_applications = {
  workloads = {
    namespace           = "argocd"
    path                = "<path>"
    repo_url            = "<repo_url>"
    target_revision     = "HEAD"
    destination         = "https://kubernetes.default.svc"
    project             = "default"
    ssh_key_secret_name = "github-ssh-key"  # Needed for private repos
    add_on_application  = false             # Indicates the root add-on application.
    values              = {}
  }
  infra = {
    namespace           = "argocd"
    path                = "<path>"
    repo_url            = "<repo_url>"
    target_revision     = "HEAD"
    destination         = "https://kubernetes.default.svc"
    project             = "default"
    ssh_key_secret_name = "github-ssh-key"  # Needed for private repos
    add_on_application  = true              # Indicates the root add-on application.
    values              = {}
  }
}
```