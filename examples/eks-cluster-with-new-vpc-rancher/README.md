# EKS Cluster Deployment with new VPC

This example is adapted from the `eks-cluster-with-new-vpc` and it deploys the following a Basic EKS Cluster in an existing VPC with Internet gateway and NAT gateway already provisioned. This example also includes a custom Kubernetes Helm AddOn - Rancher that will automatically install Rancher the helm chart.

## Install
```sh
terraform apply -target="module.eks_blueprints" -auto-approve
terraform apply -target="module.eks_blueprints_kubernetes_addons" -auto-approve
```


## Setup KUBE_CONFIG
```sh
aws eks --region us-east-1 update-kubeconfig --name eks-dev-rancher
```
## Cleanup
To clean up your environment, destroy the Terraform modules in reverse order.

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
```