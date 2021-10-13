# AWS Load Balancer Controller 

The [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) manages AWS Elastic Load Balancers for a Kubernetes cluster. The controller provisions the following resources:

* An AWS Application Load Balancer (ALB) when you create a Kubernetes Ingress.
* An AWS Network Load Balancer (NLB) when you create a Kubernetes Service of type LoadBalancer. 

For more information about AWS Load Balancer Controller please see the [official documentation](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html).

## Usage

```hcl
aws_lb_ingress_controller_enable = true
aws_lb_image_repo_name       = "amazon/aws-load-balancer-controller"
aws_lb_image_tag             = "v2.2.4"
aws_lb_helm_chart_version    = "1.2.7"
aws_lb_helm_repo_url         = "https://aws.github.io/eks-charts"
aws_lb_helm_helm_chart_name  = "aws-load-balancer-controller"
```

To validate that controller is running, ensure that controller deployment is in RUNNING state:

```sh
# Assuming controller is installed in kube-system namespace
$ kubectl get deployments -n kube-system
NAME                                                       READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller                               2/2     2            2           3m58s
```
#### AWS Service annotations for LB Ingress Controller

Here is the link to get the AWS ELB [service annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/service/annotations/) for LB Ingress controller