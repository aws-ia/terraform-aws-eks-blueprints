# Spark History Server

[Spark Web UI](https://spark.apache.org/docs/latest/web-ui.html#web-ui) can be enabled by this Add-on.
This Add-on deploys Spark History Server and fetches the Spark Event logs stored in S3. Spark Web UI can be exposed via Ingress and LoadBalancer with `values.yaml`.
Alternatively, you can port-forward on spark-history-server service. e.g.,  `kubectl port-forward services/spark-history-server 18085:80 -n spark-history-server`

## Usage

[Spark History Server](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/modules/kubernetes-addons/spark-k8s-operator) can be deployed by enabling the add-on via the following.

### Basic Example

```
enable_spark_history_server   = true
spark_history_server_s3a_path = "s3a://<ENTER_S3_BUCKET_NAME>/<PREFIX_FOR_SPARK_EVENT_LOGS>/"
```

### Advanced Example

```
enable_spark_history_server = true

# IAM policy used by IRSA role. It's recommended to create a dedicated IAM policy to access your s3 bucket
spark_history_server_irsa_policies = ["<IRSA_POLICY_ARN>"]

# NOTE: This block requires passing the helm values.yaml
# spark_history_server_s3a_path won't be used when you pass custom `values.yaml`. s3a path is passed via `sparkHistoryOpts` in `values.yaml`

spark_history_server_helm_config = {
    name             = "spark-history-server"
    chart            = "spark-history-server"
    repository       = "https://hyper-mesh.github.io/spark-history-server"
    version          = "1.0.0"
    namespace        = "spark-history-server"
    timeout          = "300"
    values = [
        <<-EOT
        serviceAccount:
          create: false

        # Enter S3 bucket with Spark Event logs location.
        # Ensure IRSA roles has permissions to read the files for the given S3 bucket
        sparkHistoryOpts: "-Dspark.history.fs.logDirectory=s3a://<ENTER_S3_BUCKET_NAME>/<PREFIX_FOR_SPARK_EVENT_LOGS>/"

        # Update spark conf according to your needs
        sparkConf: |-
          spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.WebIdentityTokenCredentialsProvider
          spark.history.fs.eventLog.rolling.maxFilesToRetain=5
          spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem
          spark.eventLog.enabled=true
          spark.history.ui.port=18080

        resources:
          limits:
            cpu: 200m
            memory: 2G
          requests:
            cpu: 100m
            memory: 1G
        EOT
    ]
}
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```
sparkHistoryServer = {
  enable = true
}
```
