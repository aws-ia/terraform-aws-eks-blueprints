# TLS with AWS PCA Issuer

This example deploys the following

- Basic EKS Cluster with VPC
- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Enables cert-manager module
- Enables cert-manager CSI driver module
- Enables aws-privateca-issuer module
- Creates AWS Certificate Manager Private Certificate Authority, enables and activates it
- Creates the CRDs to fetch `tls.crt`, `tls.key` and `ca.crt` , which will be available as Kubernetes Secret. Now you may mount the secret in the application for end to end TLS.

## How to Deploy

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply -target module.vpc
terraform apply -target module.eks
terraform apply

```

Enter `yes` at command prompt to apply

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the CoreDNS deployment for Fargate.

1. Check the Terraform provided Output, to update your `kubeconfig`

```hcl
Apply complete! Resources: 63 added, 0 changed, 0 destroyed.

Outputs:

configure_kubectl = "aws eks --region us-west-2 update-kubeconfig --name fully-private-cluster"
```

2. Run `update-kubeconfig` command, using the Terraform provided Output, replace with your `$AWS_REGION` and your `$CLUSTER_NAME` variables.

```sh
aws eks --region <$AWS_REGION> update-kubeconfig --name <$CLUSTER_NAME>
```

3. List all the pods running in `aws-privateca-issuer` and `cert-manager` namespace

```sh
kubectl get pods -n aws-privateca-issuer
kubectl get pods -n cert-manager
```

4. View the `certificate` status in the `default` Namespace. It should be in `Ready` state, and be pointing to a `secret` created in the same Namespace.

```sh
kubectl get certificate -o wide
NAME      READY   SECRET                  ISSUER                    STATUS                                          AGE
example   True    example-clusterissuer   tls-with-aws-pca-issuer   Certificate is up to date and has not expired   41m

kubectl get secret example-clusterissuer
NAME                    TYPE                DATA   AGE
example-clusterissuer   kubernetes.io/tls   3      43m
```

## Cleanup

To clean up your environment, destroy the Terraform modules in reverse order.

Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

```sh
terraform destroy -target module.eks_blueprints_kubernetes_addons -auto-approve
terraform destroy -target module.eks -auto-approve
terraform destroy -auto-approve
```
