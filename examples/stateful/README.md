# Stateful EKS Cluster

## Features

- [velero](https://github.com/vmware-tanzu/velero) for cluster backup and restore

## TODO

- Persistent volumes
- Datastores (RDBMs, cache, queue, etc.)

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

- For validating `velero` see [here](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/velero#validate)

Enter `yes` at command prompt to apply

## Destroy

To teardown and remove the resources created in this example:

```bash
terraform destroy -target module.eks_blueprints_kubernetes_addons
terraform destroy
```

Enter `yes` at each command prompt to destroy
