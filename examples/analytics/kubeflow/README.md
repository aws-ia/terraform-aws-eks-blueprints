# Kubeflow on EKS
The Kubeflow project is dedicated to making deployments of machine learning (ML) workflows on Kubernetes simple, portable and scalable.
Our goal is not to recreate other services, but to provide a straightforward way to deploy best-of-breed open-source systems for ML to diverse infrastructures.
Anywhere you are running Kubernetes, you should be able to run Kubeflow.

This example deploys the following resources

- Creates EKS Cluster Control plane with public endpoint (for demo purpose only) with a managed node group
- Deploys EBS/EFS CSI driver and Kubeflow pipeline on the EKS cluster

Note: we use EKS 1.21 here which is the latest EKS version supported by Kubeflow. see reference below <br>
https://awslabs.github.io/kubeflow-manifests/docs/about/eks-compatibility/

## Prerequisites:

Ensure that you have installed the following tools on your machine.

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)



## Deploy EKS Cluster with Kubeflow feature

Clone the repository

```sh
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

Navigate into one of the example directories and run `terraform init`

```sh
cd examples/analytics/kubeflow
terraform init
```

Run Terraform plan to verify the resources created by this execution.

```sh
terraform plan
```

**Deploy the EKS cluster with kubeflow pipeline feature**

```sh
terraform apply
```

Enter `yes` to apply.



## Verify the resources

Let’s verify the resources created by Steps above.



kubectl get nodes # Output shows the EKS Managed Node group nodes

kubectl get ns | kubeflow # Output shows kubeflow namespace

kubectl get pods --namespace=kubeflow-pipelines # Output shows kubeflow pods



## Execute Machine learning jobs on Kubeflow
log into Kubeflow pipeline UI by creating a port-forward to the ml-pipeline-ui service<br>

```sh
kubectl port-forward svc/ml-pipeline-ui 9000:80 -n =kubeflow-pipelines
```
and open this browser: http://localhost:9000/#/pipelines
more pipeline examples can be found at https://www.kubeflow.org/docs/components/pipelines/tutorials/

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
```
