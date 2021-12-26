# Spark on K8s Operator with EKS.

This example deploys an EKS Cluster running the Spark K8s operator into a new VPC.

 - Creates a new sample VPC, 3 Private Subnets and 3 Public Subnets
 - Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
 - Creates EKS Cluster Control plane with public endpoint (for demo reasons only) with one managed node group
 - Deploys Metrics server, Cluster Autoscaler and EMR on EKS Addon

 This will install the Kubernetes Operator for Apache Spark into the namespace spark-operator. The operator by default watches and handles SparkApplications in every namespaces. If you would like to limit the operator to watch and handle SparkApplications in a single namespace, e.g., default instead, add the following option to the helm install command:

## Step1:

Enable Spark-K8S-Operator on EKS Cluster

```hcl
 #---------------------------------------
  # ENABLE SPARK on K8S OPERATOR
  #---------------------------------------
  spark_on_k8s_operator_enable = true

  # Optional Map value
  spark_on_k8s_operator_helm_chart = {
    name             = "spark-operator"
    chart            = "spark-operator"
    repository       = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
    version          = "1.1.6"
    namespace        = "spark-k8s-operator"
    timeout          = "1200"
    create_namespace = true
    values           = [templatefile("${path.module}/k8s_addons/spark-k8s-operator-values.yaml", {})]

  }
```

##Step2:
Create Spark Namespace, Service Account and ClusterRole and ClusterRole Binding for the jobs

```shell script
./examples/8-Spark-on-k8s-operator-with-EKS/test/spark-k8s-templates/spark-teams-setup.yaml
```

##Step3:
Execute first spark job with simple example

```shell script
.examples/8-Spark-on-k8s-operator-with-EKS/test/spark-k8s-templates/pyspark-pi-job.yaml
```

##Step4:
