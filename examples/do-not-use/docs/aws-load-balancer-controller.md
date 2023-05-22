# AWS Load Balancer Controller.

[AWS Load Balancer Controller ](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) is a controller to help manage Elastic Load Balancers for a Kubernetes cluster. This Add-on deploys this controller in an Amazon EKS Cluster.

## Usage

In order to deploy the AWS Load Balancer Controller Addon via [EKS Blueprints Addons](https://github.com/aws-ia/terraform-aws-eks-blueprints-addons), reference the following parameters under the `module.eks_blueprints_addons`.

```hcl
module "eks_blueprints_addons" {

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = module.vpc.vpc_id
      },
      {
        name  = "podDisruptionBudget.maxUnavailable"
        value = 1
      },
    ]
  }
```
### Helm Chart customization

It's possible to customize your deployment using the Helm Chart parameters inside the `aws_load_balancer_controller` configuration block:

```hcl
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = module.vpc.vpc_id
      },
      {
        name  = "podDisruptionBudget.maxUnavailable"
        value = 1
      },
      {
        name  = "resources.requests.cpu"
        value = 100m
      },
      {
        name  = "resources.requests.memory"
        value = 128Mi
      },
    ]
  }
}
```

You can find all available Helm Chart parameter values [here](https://github.com/kubernetes-sigs/aws-load-balancer-controller/blob/main/helm/aws-load-balancer-controller/values.yaml).


## Validate

1. To validate the deployment, check if the `aws-load-balancer-controller` Pods were created in the `kube-system` Namespace, as the following example.

```sh
kubectl -n kube-system get pods | grep aws-load-balancer-controller
NAMESPACE       NAME                                            READY   STATUS    RESTARTS   AGE
kube-system     aws-load-balancer-controller-6cbdb58654-fvskt   1/1     Running   0          26m
kube-system     aws-load-balancer-controller-6cbdb58654-sc7dk   1/1     Running   0          26m
```

2. Create a Kubernetes Ingress, using the `alb` IngressClass, pointing to an existing Service. In this example we'll use a Service called `example-svc`.

```sh
kubectl create ingress example-ingress --class alb --rule="/*=example-svc:80" \
--annotation alb.ingress.kubernetes.io/scheme=internet-facing \
--annotation alb.ingress.kubernetes.io/target-type=ip
```

```sh
kubectl get ingress  
NAME                CLASS   HOSTS   ADDRESS                                                                 PORTS   AGE
example-ingress     alb     *       k8s-example-ingress-7e0d6f03e7-1234567890.us-west-2.elb.amazonaws.com   80      4m9s
```

## Resources

[GitHub Repo](https://github.com/kubernetes-sigs/aws-load-balancer-controller/)
[Helm Chart](https://github.com/kubernetes-sigs/aws-load-balancer-controller/tree/main/helm/aws-load-balancer-controller)
[AWS Docs](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
