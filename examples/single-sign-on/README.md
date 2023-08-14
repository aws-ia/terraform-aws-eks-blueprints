# Single Sign-On for Amazon EKS Cluster

These examples demonstrates how to deploy an Amazon EKS cluster that is deployed on the AWS Cloud, integrated with an external Identity Provider (IdP) for Single Sign-On (SSO) authentication. The authorization configuration still being done using Kubernetes Role-based access control (RBAC). At this time we have integration with the following IdPs.

- [IAM Identity Center (successor to AWS Single Sign-On)](https://aws.amazon.com/iam/identity-center/)
- [Okta](https://www.okta.com/)

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision these examples, run the following commands:

```sh
terraform init
terraform apply -target module.vpc 
terraform apply -target module.eks
terraform apply
```

Enter `yes` at command prompt to apply

## Validate

**Specific instructions for each SSO provider are available in the respective directories.**

## Destroy

To teardown and remove the resources created in these examples:

```sh
terraform destroy -auto-approve
```
