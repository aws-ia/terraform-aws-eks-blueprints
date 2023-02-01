# AWS Load Balancer Controller

The [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) manages AWS Elastic Load Balancers for a Kubernetes cluster. The controller provisions the following resources:

* An AWS Application Load Balancer (ALB) when you create a Kubernetes Ingress.
* An AWS Network Load Balancer (NLB) when you create a Kubernetes Service of type LoadBalancer.

For more information about AWS Load Balancer Controller please see the [official documentation](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html).

## Usage

```hcl
enable_aws_load_balancer_controller = true
```

You can optionally customize the Helm chart that deploys `aws-lb-ingress-controller` via the following configuration.

```hcl
  enable_aws_load_balancer_controller = true
  # Optional
  aws_load_balancer_controller_helm_config = {
    name                       = "aws-load-balancer-controller"
    chart                      = "aws-load-balancer-controller"
    repository                 = "https://aws.github.io/eks-charts"
    version                    = "1.3.1"
    namespace                  = "kube-system"
    values = [templatefile("${path.module}/values.yaml", {})]
  }
```

To validate that controller is running, ensure that controller deployment is in RUNNING state:

```sh
# Assuming controller is installed in kube-system namespace
$ kubectl get deployments -n kube-system
NAME                                                       READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller                               2/2     2            2           3m58s
```
#### AWS Service annotations for LB Ingress Controller

Here is the link to get the AWS ELB [service annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/service/annotations/) for LB Ingress controller.

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps.

```
awsLoadBalancerController = {
  enable             = true
  serviceAccountName = "<service_account>"
}
```

### IRSA is too long

If the IAM role is too long, override the service account name in the `helm_config` to create a shorter role name.

```hcl
  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller_helm_config = {
    service_account = "aws-lb-sa"
  }
```
