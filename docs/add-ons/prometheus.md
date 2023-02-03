# Prometheus

Prometheus is an open source monitoring and alerting service. Prometheus joined the Cloud Native Computing Foundation in 2016 as the second hosted project, after Kubernetes.

This project provides support for installing a open source Prometheus server in your EKS cluster and for deploying a new Prometheus instance via [Amazon Managed Service for Prometheus](https://aws.amazon.com/prometheus/).

## Usage

The following will deploy the Prometheus server into an EKS Cluster and provision a new Amazon Managed Service for Prometheus instance.

```hcl-terraform
# Creates the AMP workspace and all the relevant IAM Roles
enable_amazon_prometheus         = true

# Deploys Prometheus server with remote write to AWS AMP Workspace
enable_prometheus             = true
```

Enable Prometheus with custom `values.yaml`

```hcl-terraform
  #---------------------------------------
  # Prometheus Server integration with Amazon Prometheus
  #---------------------------------------
  # Amazon Prometheus Configuration to integrate with Prometheus Server Add-on
  enable_amazon_prometheus = true
  amazon_prometheus_workspace_endpoint = "<Enter Amazon Workspace Endpoint>"

  enable_prometheus = true
  # Optional Map value
  prometheus_helm_config = {
    name       = "prometheus"                                         # (Required) Release name.
    repository = "https://prometheus-community.github.io/helm-charts" # (Optional) Repository URL where to locate the requested chart.
    chart      = "prometheus"                                         # (Required) Chart name to be installed.
    version    = "15.3.0"                                             # (Optional) Specify the exact chart version to install. If this is not specified, it defaults to the version set within default_helm_config: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/prometheus/locals.tf
    namespace  = "prometheus"                                         # (Optional) The namespace to install the release into.
    values = [templatefile("${path.module}/prometheus-values.yaml", {
      operating_system = "linux"
    })]
  }
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```hcl-terraform
prometheus = {
  enable             = true
  ampWorkspaceUrl    = "<workspace_url>"
  roleArn            = "<role_arn>"
  serviceAccountName = "<service_account>"
}
```
