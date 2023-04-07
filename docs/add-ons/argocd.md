# ArgoCD

[ArgoCD](https://argo-cd.readthedocs.io/en/stable/) Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

Application definitions, configurations, and environments should be declarative and version controlled. Application deployment and lifecycle management should be automated, auditable, and easy to understand.

## Usage

ArgoCD can be deployed by enabling the add-on via the following.

```hcl
enable_argocd = true
```

### Admin Password

ArgoCD has a built-in `admin` user that has full access to the ArgoCD instance. By default, Argo will create a password for the admin user.

See the [ArgoCD documentation](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/) for additional details on managing users.

### Customizing the Helm Chart

You can customize the Helm chart that deploys `ArgoCD` via the following configuration:

```hcl
argocd_helm_config = {
  name             = "argo-cd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "<chart_version>"
  namespace        = "argocd"
  timeout          = "1200"
  create_namespace = true
  values = [templatefile("${path.module}/argocd-values.yaml", {})]
}
```

### Bootstrapping

The framework provides an approach to bootstrapping workloads and/or additional add-ons by leveraging the ArgoCD [App of Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) pattern.

The following code example demonstrates how you can supply information for a repository in order to bootstrap multiple workloads in a new EKS cluster. The example leverages a [sample App of Apps repository](https://github.com/aws-samples/eks-blueprints-workloads.git).

```hcl
argocd_applications = {
  addons = {
    path                = "chart"
    repo_url            = "https://github.com/aws-samples/eks-blueprints-add-ons.git"
    add_on_application  = true # Indicates the root add-on application.
  }
}
```

### Add-ons

A common operational pattern for EKS customers is to leverage Infrastructure as Code to provision EKS clusters (in addition to other AWS resources), and ArgoCD to manage cluster add-ons. This can present a challenge when add-ons managed by ArgoCD depend on AWS resource values which are created via Terraform execution (such as an IAM ARN for an add-on that leverages IRSA), to function properly. The framework provides an approach to bridging the gap between Terraform and ArgoCD by leveraging the ArgoCD [App of Apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/) pattern.

To indicate that ArgoCD should responsible for managing cluster add-ons (applying add-on Helm charts to a cluster), you can set the `argocd_manage_add_ons` property to true. When this flag is set, the framework will still provision all AWS resources necessary to support add-on functionality, but it will not apply Helm charts directly via the Terraform Helm provider.

Next, identify which ArgoCD Application will serve as the add-on configuration repository by setting the `add_on_application` flag to true. When this flag is set, the framework will aggregate AWS resource values that are needed for each add-on into an object. It will then pass that object to ArgoCD via the values map of the Application resource. [See here](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/locals.tf#L4) for the values object that gets passed to the ArgoCD add-ons Application.

Sample configuration can be found below:

```hcl
enable_argocd           = true
argocd_manage_add_ons   = true
argocd_applications     = {
  addons = {
    path                = "chart"
    repo_url            = "https://github.com/aws-samples/eks-blueprints-add-ons.git"
    add_on_application  = true # Indicates the root add-on application.
  }
}
```

### Private Repositories

In order to leverage ArgoCD with private Git repositories, you must supply a private SSH key to Argo. The framework provides support for doing so via an integration with AWS Secrets Manager.

To leverage private repositories, do the following:

1. Create a new secret in AWS Secrets Manager for your desired region. The value for the secret should be a private SSH key for your Git provider.
2. Set the `ssh_key_secret_name` in each Application's configuration as the name of the secret.

Internally, the framework will create a Kubernetes Secret, which ArgoCD will leverage when making requests to your Git provider. See the example configuration below.

```hcl
enable_argocd           = true
argocd_manage_add_ons   = true
argocd_applications     = {
  addons = {
    path                = "chart"
    repo_url            = "git@github.com:aws-samples/eks-blueprints-add-ons.git"
    project             = "default"
    add_on_application  = true              # Indicates the root add-on application.
    ssh_key_secret_name = "github-ssh-key"  # Needed for private repos
    insecure            = false # Set to true to disable the server's certificate verification
  }
}
```

### Complete Example

The following demonstrates a complete example for configuring ArgoCD.

```hcl
enable_argocd                       = true
argocd_manage_add_ons               = true

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
    path                = "envs/dev"
    repo_url            = "https://github.com/aws-samples/eks-blueprints-workloads.git"
    values              = {}
    type                = "helm"            # Optional, defaults to helm.
  }
  kustomize-apps = {
    /*
      This points to a single application with no overlays, but it could easily
      point to a a specific overlay for an environment like "dev", and/or utilize
      the ArgoCD app of apps model to install many additional ArgoCD apps.
    */
    path                = "argocd-example-apps/kustomize-guestbook/"
    repo_url            = "https://github.com/argoproj/argocd-example-apps.git"
    type                = "kustomize"
  }
  addons = {
    path                = "chart"
    repo_url            = "git@github.com:aws-samples/eks-blueprints-add-ons.git"
    add_on_application  = true              # Indicates the root add-on application.
                                            # If provided, the type must be set to "helm" for the root add-on application.
    ssh_key_secret_name = "github-ssh-key"  # Needed for private repos
    values              = {}
    type                = "helm"            # Optional, defaults to helm.
    #ignoreDifferences   = [ # Enable this to ignore children apps' sync policy
    #  {
    #    group        = "argoproj.io"
    #    kind         = "Application"
    #    jsonPointers = ["/spec/syncPolicy"]
    #  }
    #]
  }
}
```
