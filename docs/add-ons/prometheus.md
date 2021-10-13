# Prometheus

Prometheus is an open source monitoring and alerting service. Prometheus joined the Cloud Native Computing Foundation in 2016 as the second hosted project, after Kubernetes.

This project provides support for installing a open source Prometheus serve in your EKS cluster and for deploying a new Prometheus instance via [Amazon Managed Service for Prometheus](https://aws.amazon.com/prometheus/). 

## Usage

The following will deploy the Prometheus server into an EKS Cluster and provision a new Amazon Managed Service for Prometheus instance. 

```hcl
# Creates the AMP workspace and all the relevent IAM Roles
aws_managed_prometheus_enable         = false
aws_managed_prometheus_workspace_name = "EKS-Metrics-Workspace"

# Deploys Pometheus server with remote write to AWS AMP Workspace
prometheus_enable             = false
prometheus_helm_chart_url     = "https://prometheus-community.github.io/helm-charts"
prometheus_helm_chart_name    = "prometheus"
prometheus_helm_chart_version = "14.4.0"
prometheus_image_tag          = "v2.26.0"
alert_manager_image_tag       = "v0.21.0"
configmap_reload_image_tag    = "v0.5.0"
node_exporter_image_tag       = "v1.1.2"
pushgateway_image_tag         = "v1.3.1"
```
