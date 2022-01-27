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
3. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Step1: Deploy EKS Cluster with Spark-K8s-Operator feature
Clone the repository

```
git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
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

<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-eks-accelerator-for-terraform"></a> [aws-eks-accelerator-for-terraform](#module\_aws-eks-accelerator-for-terraform) | ../../.. | n/a |
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws | v3.2.0 |
| <a name="module_kubernetes-addons"></a> [kubernetes-addons](#module\_kubernetes-addons) | ../../../modules/kubernetes-addons | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

No inputs.

## Outputs

No outputs.

<!--- END_TF_DOCS --->
