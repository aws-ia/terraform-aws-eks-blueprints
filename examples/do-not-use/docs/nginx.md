# Nginx

This add-on installs [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) on Amazon EKS. The Nginx ingress controller uses [Nginx](https://www.nginx.org/) as a reverse proxy and load balancer.

Other than handling Kubernetes ingress objects, this ingress controller can facilitate multi-tenancy and segregation of workload ingresses based on host name (host-based routing) and/or URL Path (path based routing).

## Usage

Nginx Ingress Controller can be deployed by enabling the add-on via the following.

```hcl
enable_ingress_nginx = true
```

You can also customize the Helm chart that deploys `ingress-nginx` via the following configuration:

```sh
$ kubectl get pods -n ingress-nginx
NAME                                       READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-f6c55fdc8-8bt2z   1/1     Running   0          44m
```

Note that the ingress controller is deployed in the `ingress-nginx` namespace.

You can optionally customize the Helm chart that deploys `nginx` via the following configuration.

```hcl
  enable_ingress_nginx = true

  ingress_nginx = {
    name          = "ingress-nginx"
    chart_version = "4.6.1"
    repository    = "https://kubernetes.github.io/ingress-nginx"
    namespace     = "ingress-nginx"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }

```
