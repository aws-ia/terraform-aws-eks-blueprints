# Nginx

This add-on installs [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) on Amazon EKS. The Nginx ingress controller uses [Nginx](https://www.nginx.org/) as a reverse proxy and load balancer.

Other than handling Kubernetes ingress objects, this ingress controller can facilitate multi-tenancy and segregation of workload ingresses based on host name (host-based routing) and/or URL Path (path based routing).

## Usage

Nginx Ingress Controller can be deployed by enabling the add-on via the following.

```hcl
enable_ingress_nginx = true
```

To validate that installation is successful run the following command:

```sh
$ kubectl get po -n kube-system
NAME                                                              READY   STATUS    RESTARTS   AGE
eks-blueprints-addon-ingress-nginx-78b8567p4q6   1/1     Running   0          4d10h
```

Note that the ingress controller is deployed in the `ingress-nginx` namespace.

You can optionally customize the Helm chart that deploys `nginx` via the following configuration.

```hcl
  enable_ingress_nginx = true

  # Optional  ingress_nginx_helm_config
  ingress_nginx_helm_config = {
    repository  = "https://kubernetes.github.io/ingress-nginx"
    version     = "4.0.17"
    values      = [file("${path.module}/values.yaml")]
  }

  nginx_irsa_policies = [] # Optional to add additional policies to IRSA
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

GitOps with ArgoCD Add-on repo is located [here](https://github.com/aws-samples/eks-blueprints-add-ons/blob/main/chart/values.yaml)

``` hcl
argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account
  }
```
