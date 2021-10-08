## AWS Load Balancer Controller

**AWS ALB Load Balancer Controller** triggers the creation of an ALB and the necessary supporting AWS resources whenever a Kubernetes  user declares an Ingress resource in the cluster. [ALB Docs](https://Kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)

[ALB Ingress Controller](helm/lb_ingress_controller/README.md) can be deployed by specifying the following line in `base.tfvars` file.

```
alb_ingress_controller_enable = true
```