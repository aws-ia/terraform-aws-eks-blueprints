# Datadog Operator
The [Datadog Operator](https://github.com/DataDog/datadog-operator) is a Kubernetes add-on that can automate the deployment of a best-practice Datadog monitoring agent on a Kubernetes cluster.

## Usage
The Datadog Operator can be deployed by enabling the add-on via the following.

```hcl
enable_datadog_operator = true
```

Once the operator is provisioned, the Datadog Agent can be deployed by creating a `DatadogAgent` resource and supplying an API key.
