# Spark on K8s Operator with EKS

This example deploys an EKS Cluster running the Spark K8s operator into a new VPC.

- Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with public endpoint (for demo reasons only) with one managed node group
- Deploys Metrics server, Cluster Autoscaler, Spark-k8s-operator, Yunikorn and Prometheus

This will install the Kubernetes Operator for Apache Spark into the namespace spark-operator.
The operator by default watches and handles SparkApplications in all namespaces.
If you would like to limit the operator to watch and handle SparkApplications in a single namespace, e.g., default instead, add the following option to the helm install command:

## Prerequisites

Ensure that you have installed the following tools on your machine.

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Step 1: Deploy EKS Cluster with Spark-K8s-Operator feature

Clone the repository

```
git clone https://github.com/aws-ia/terraform-aws-eks-blueprints.git
```

Navigate into one of the example directories and run `terraform init`

```
cd examples/analytics/spark-k8s-operator
terraform init
```

Run Terraform plan to verify the resources created by this execution.

```
export AWS_REGION=<enter-your-region>   # Select your own region
terraform plan
```

Deploy the pattern

```
terraform apply
```

Enter `yes` to apply.

## Execute Sample Spark Job on EKS Cluster with Spark-k8s-operator:

- Create Spark Namespace, Service Account and ClusterRole and ClusterRole Binding for the jobs

```shell script
   cd examples/analytics/spark-k8s-operator/k8s-schedular
   kubectl apply -f spark-teams-setup.yaml
```

- Execute first spark job with simple example

```shell script
  cd examples/analytics/spark-k8s-operator/k8s-schedular
  kubectl apply -f pyspark-pi-job.yaml
```

- Verify the Spark job status

```shell script
  kubectl get sparkapplications -n spark-ns

  kubectl describe sparkapplication pyspark-pi -n spark-ns
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_blueprints"></a> [eks\_blueprints](#module\_eks\_blueprints) | ../../.. | n/a |
| <a name="module_eks_blueprints_kubernetes_addons"></a> [eks\_blueprints\_kubernetes\_addons](#module\_eks\_blueprints\_kubernetes\_addons) | ../../../modules/kubernetes-addons | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
