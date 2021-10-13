# Kubernetes Addons Module

The `kubernetes-addons` module within this framework allows you to deploy Kubernetes add-ons using both the Terraform Helm and Kubernetes providers with simple **true/false** flags.

| Add-on    | Description   |
|-----------|-----------------
| Agones |
| FluentBit |
| OpenTelemetry |
| cert-manager |
| Cluster Autoscaler |
| AWS Load Balancer Controller
| Metrics Server |
| Nginx |
| Prometheus |
| Traefik |
| Windows VPC Controller |

## Installation 

By default, the module is configured to fetch Helm Charts from Open Source repositories and Docker images from Docker Hub/Public ECR repositories. This requires outbound Internet connection from your EKS Cluster.  

Alternatively you can download the Docker images for each add-on and push them to an AWS ECR repo and this can be accessed within an existing VPC using an ECR endpoint. For instructions on how to do so download existing images, and push them to ECR, see [ECR instructions](../docs/ecr-instructions.md). Each individual add-on directory contains a README.md file with info on the Helm repositories each add-on uses.