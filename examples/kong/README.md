# Kong EKS Cluster

## Features

- [kong](https://docs.konghq.com/kubernetes-ingress-controller/latest/deployment/eks/) for open-source Ingress Controller for Kubernetes that offers API management capabilities with a plugin architecture. 

## TODO

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```bash
terraform init
terraform apply
```

## Validate

- For validating `kong` see [here](https://docs.konghq.com/kubernetes-ingress-controller/2.7.x/guides/getting-started/)

## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
