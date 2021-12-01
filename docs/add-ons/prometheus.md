# Prometheus

Prometheus is an open source monitoring and alerting service. Prometheus joined the Cloud Native Computing Foundation in 2016 as the second hosted project, after Kubernetes.

This project provides support for installing a open source Prometheus server in your EKS cluster and for deploying a new Prometheus instance via [Amazon Managed Service for Prometheus](https://aws.amazon.com/prometheus/).

## Usage

The following will deploy the Prometheus server into an EKS Cluster and provision a new Amazon Managed Service for Prometheus instance.

```hcl
# Creates the AMP workspace and all the relevent IAM Roles
aws_managed_prometheus_enable         = false
aws_managed_prometheus_workspace_name = "EKS-Metrics-Workspace"

# Deploys Pometheus server with remote write to AWS AMP Workspace
prometheus_enable             = false
```

### GitOps Configuration

The following properties are made available for use when managing the add-on via GitOps

```
prometheus = {
  enable             = true
  ampWorkspaceUrl    = "<workspace_url>"
  roleArn            = "<role_arn>"
  serviceAccountName = "<service_account_name>"
}
```
