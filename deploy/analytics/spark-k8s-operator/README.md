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
cd deploy/analytics/spark-k8s-operator
terraform init
```

Run Terraform plan to verify the resources created by this execution.

```
export AWS_REGION="eu-west-1"   # Select your own region
terraform plan

```

Deploy the pattern

```
terraform apply
```

Enter `yes` to apply.

## Steps to enable the Spark K8s Operator on EKS Cluster

Enable Spark-K8S-Operator on EKS Cluster

```hcl
 #---------------------------------------
  # ENABLE SPARK on K8S OPERATOR
  #---------------------------------------
  enable_spark_k8s_operator = true

  # Optional Map value
  spark_k8s_operator_helm_config = {
    name             = "spark-operator"
    chart            = "spark-operator"
    repository       = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
    version          = "1.1.6"
    namespace        = "spark-k8s-operator"
    timeout          = "1200"
    create_namespace = true
    values           = [templatefile("${path.module}/helm_values/spark-k8s-operator-values.yaml", {})]
  }
```

## Execute Sample SPatk Job on EKS Cluster with Spark-k8s-operator:
 - Create Spark Namespace, Service Account and ClusterRole and ClusterRole Binding for the jobs

```shell script
   cd deploy/analytics/spark-k8s-operator/k8s-schedular
   kubectl apply -f spark-teams-setup.yaml
```

- Execute first spark job with simple example

```shell script
  cd deploy/analytics/spark-k8s-operator/k8s-schedular
  kubectl apply -f pyspark-pi-job.yaml
```



<!--- BEGIN_TF_DOCS --->
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: MIT-0

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.66.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.6.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.66.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-eks-accelerator-for-terraform"></a> [aws-eks-accelerator-for-terraform](#module\_aws-eks-accelerator-for-terraform) | github.com/aws-samples/aws-eks-accelerator-for-terraform | n/a |
| <a name="module_aws_vpc"></a> [aws\_vpc](#module\_aws\_vpc) | terraform-aws-modules/vpc/aws | v3.2.0 |
| <a name="module_kubernetes-addons"></a> [kubernetes-addons](#module\_kubernetes-addons) | github.com/aws-samples/aws-eks-accelerator-for-terraform//modules/kubernetes-addons | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

No inputs.

## Outputs

No outputs.

<!--- END_TF_DOCS --->
