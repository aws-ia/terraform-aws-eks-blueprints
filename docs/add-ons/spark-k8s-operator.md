# Spark K8S Operator
The Kubernetes Operator for Apache Spark aims to make specifying and running Spark applications as easy and idiomatic as running other workloads on Kubernetes. It uses Kubernetes custom resources for specifying, running, and surfacing status of Spark applications. For a complete reference of the custom resource definitions, please refer to the API Definition. For details on its design, please refer to the design doc. It requires Spark 2.3 and above that supports Kubernetes as a native scheduler backend.

For complete project documentation, please visit the [Spark K8S Operator documentation site](https://github.com/GoogleCloudPlatform/spark-on-k8s-operator).

## Usage

[Spark K8S Operator](kubernetes-addons/spark-k8s-operator/README.md) can be deployed by enabling the add-on via the following.

### Basic Example

```hcl
  spark_on_k8s_operator_enable = true
```

### Advanced Example
```hcl
  spark_on_k8s_operator_enable = true
  # Optional Map value
  # NOTE: This block requires passing the helm values.yaml
  spark_on_k8s_operator_helm_chart = {
    name             = "spark-operator"
    chart            = "spark-operator"
    repository       = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
    version          = "1.1.6"
    namespace        = "spark-k8s-operator"
    timeout          = "1200"
    create_namespace = true
    values = [templatefile("${path.module}/spark-k8s-operator-values.yaml", {})]

  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```
sparkK8sOperator = {
  enable = true
}
```
