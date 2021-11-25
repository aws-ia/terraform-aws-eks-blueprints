# Nginx

This add-on installs [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) on Amazon EKS. The Nginx ingress controller uses [Nginx](https://www.nginx.org/) as a reverse proxy and load balancer.

Other than handling Kubernetes ingress objects, this ingress controller can facilitate multi-tenancy and segregation of workload ingresses based on host name (host-based routing) and/or URL Path (path based routing).

## Usage

[Nginx Ingress Controller](kubernetes-addons/nginx-ingress/README.md) can be deployed by enabling the add-on via the following.

```hcl
nginx_ingress_controller_enable = true
```

To validate that installation is successful run the following command:

```bash
$ kubectl get po -n kube-system
NAME                                                              READY   STATUS    RESTARTS   AGE
ssp-addon-nginx-ingress-78b8567p4q6   1/1     Running   0          4d10h
```

Note that the ingress controller is deployed in the `kube-system` namespace.

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```
ingressNginx = {
  enable       = true
  logGroupName = "<log_group_name>"
  logGroupArn  = "<log_group_arn>"
}
```
