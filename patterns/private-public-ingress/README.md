# Amazon EKS Private and Public Ingress example

This example demonstrates how to provision an Amazon EKS cluster with two  ingress-nginx controllers; one to expose applications publicly and the other to expose applications internally. It also assigns security groups to the Network Load Balancers used to expose the internal and external ingress controllers.

This solution:

- Installs an ingress-nginx controller for public traffic
- Installs an ingress-nginx controller for internal traffic

To expose your application services via an `Ingress` resource with this solution you can set the respective `ingressClassName` as either `ingress-nginx-external` or `ingress-nginx-internal`.

Refer to the [documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller) for `AWS Load Balancer controller` configuration options.

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

!!! danger "TODO"
    Add in validation steps

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
