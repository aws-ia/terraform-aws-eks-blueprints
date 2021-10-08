## Traefik Ingress Controller

**Traefik is an open source Kubernetes  Ingress Controller**. The Traefik Kubernetes  Ingress provider is a Kubernetes  Ingress controller; that is to say, it manages access to cluster services by supporting the Ingress specification. For more details about [Traefik can be found here](https://doc.traefik.io/traefik/providers/Kubernetes-ingress/)

[Traefik Ingress Controller](helm/traefik_ingress/README.md) can be deployed by specifying the following line in `base.tfvars` file.

```
traefik_ingress_controller_enable = true
```