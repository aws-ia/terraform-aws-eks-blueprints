# Kubernetes Addons Module

The `kubernetes-addons` module within this framework allows you to deploy Kubernetes add-ons using both the Terraform Helm and Kubernetes providers with simple **true/false** flags.

The framework currently provides support for the following add-ons.

| Add-on    | Description   |
|-----------|-----------------
| [Agones](./agones) | Deploys Agones into an EKS cluster. |
| [AWS for Fluent Bit](./aws-for-fluent-bit) | Deploys Fluent Bit into an EKS cluster. |
| [AWS Load Balancer Controller](./fargate-fluent-bit) | Deploys the AWS Load Balancer Controller into an EKS cluster. |
| [AWS Distro for Open Telemetry](./aws-open-telemetry) | Deploys the AWS Open Telemetry Collector into an EKS cluster. |
| [cert-manager](./cert-manager) | Deploys cert-manager into an EKS cluster. |
| [Cluster Autoscaler](./cluster-autoscaler) | Deploys the standard cluster autoscaler into an EKS cluster. |
| [Fluent Bit for Fargate](./fargate-fluent-but) | Adds Fluent Bit support for EKS Fargate |
| [EKS Managed Add-ons](./managed-add-ons) | Enables EKS managed add-ons. |
| [Metrics Server](./metrics-server) | Deploys the Kubernetes Metrics Server into an EKS cluster. |
| [Nginx](./nginx) | Deploys the NGINX Ingress Controller into an EKS cluster. |
| [Prometheus](./prometheus) | Deploys Prometheus into an EKS cluster. |
| [Traefik](./traefik) | Deploys Traefik Proxy into an EKS cluster.

## Usage

In order to deploy add-ons with the default configuration, simply enable the add-ons via Terraform properties.

```hcl
metrics_server_enable = true            # Deploys Metrics Server Addon

cluster_autoscaler_enable = true        # Deploys Cluster Autoscaler Addon

prometheus_enable = true                # Deploys Prometheus Addon
```

The following demonstrates how you can supply optional Helm configuration, including a dedicated values.yaml file.

```hcl
metrics_server_helm_chart = {
    name           = "metrics-server"
    repository     = "https://kubernetes-sigs.github.io/metrics-server/"
    chart          = "metrics-server"
    version        = "3.5.0"
    namespace      = "kube-system"
    timeout        = "1200"

    # (Optional) Example to pass metrics-server-prometheus-values.yaml from your local repo
    values = [templatefile("${path.module}/k8s_addons/metrics-server-values.yaml", {
        operating_system                = "linux"
    })]
}
```

By default, the module is configured to fetch Helm Charts from Open Source repositories and Docker images from Docker Hub/Public ECR repositories. This requires outbound Internet connection from your EKS Cluster.

Alternatively you can download the Docker images for each add-on and push them to an AWS ECR repo and this can be accessed within an existing VPC using an ECR endpoint. For instructions on how to do so download existing images, and push them to ECR, see [ECR instructions](../advanced/ecr-instructions.md). Each individual add-on directory contains a README.md file with info on the Helm repositories each add-on uses.
