# Amazon EKS Private and Public Ingress example

This example demonstrates how to provision an Amazon EKS cluster with two  ingress-nginx controllers; one to expose applications publicly and the other to expose applications internally. It also assigns security groups to the Network Load Balancers used to expose the internal and external ingress controllers.

This solution:
* Deploys Amazon EKS, with 1 Managed Node Group using the Bottlerocket Amazon EKS Optimized AMI spread accross 3 availability zones.
* Installs the AWS Load Balancer controller for creating Network Load Balancers and Application Load Balancers. This is the recommended approach instead of the built-in AWS cloud provider load balancer controller.
* Installs an nginx ingress controller for public traffic
* Intstalls an nginx ingress controller for internal traffic

To expose your application services via an `Ingress` resource with this solution you can set the respective `ingressClassName` as either `nginx-ingress-external` or `nginx-ingress-internal`.

Refer to the [documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller) for `AWS Load Balancer controller` configuration options.

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply
```

Enter `yes` at command prompt to apply

## Destroy

To teardown and remove the resources created in this example:

```sh
terraform destroy -auto-approve
```
