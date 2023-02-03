# Strimzi Operator for Apache Kafka
[Apache Kafka](https://kafka.apache.org/intro) is an open-source distributed event streaming platform used by thousands of companies for high-performance data pipelines, streaming analytics, data integration, and mission-critical applications.
This addon deploys Strimizi Kafka Operator and it makes it really easy to spin up a Kafka cluster in minutes.

For complete project documentation, please visit the [Strimzi Kafka](https://strimzi.io/).

## Usage
Strimzi Kafka Operator can be deployed by enabling the add-on via the following. Check out the full [example](https://github.com/awslabs/data-on-eks/tree/main/streaming/kafka) to deploy the EKS Cluster with Kafka.

```hcl
enable_strimzi_kafka_operator = true
```

You can optionally customize the Helm chart that deploys `Kafka` via the following configuration.

```hcl
  enable_strimzi_kafka_operator = true
  # Optional  kafka_helm_config
  strimzi_kafka_operator_helm_config = {
    name             = local.name
    chart            = "strimzi-kafka-operator"
    repository       = "https://strimzi.io/charts/"
    version          = "0.31.1"
    namespace        = local.name
    create_namespace = true
    values           = [templatefile("${path.module}/values.yaml", {})]
    description      = "Strimzi - Apache Kafka on Kubernetes"
  }
```

### GitOps Configuration
The following properties are made available for use when managing the add-on via GitOps.

```hcl
strimziKafkaOperator = {
  enable = true
}
```
