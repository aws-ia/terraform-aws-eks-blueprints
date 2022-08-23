# Datadog Operator
The [Datadog Operator](https://github.com/DataDog/datadog-operator) is a Kubernetes add-on that can automate the deployment of a best-practice Datadog monitoring agent on a Kubernetes cluster.

## Usage
The Datadog Operator can be deployed by enabling the add-on via the following.

```hcl
enable_datadog_operator = true
```

An API key is required, this can be passed as a variable:

```hcl
datadog_api_key = <key>
```

or by creating a secret external to the Terraform and passing in the secret name:

```hcl
datadog_operator_helm_config = {
  datadog_agent = {
    spec = {
      credentials = {
        apiSecret = {
          secretName = "<secret-name>"
          keyName = "<secret-key-name>"
        }      
      }
    }
  }
}
```
