# Deploy Amazon Managed Service for Prometheus(AMP) and Amazon Managed Service for Grafana in EKS Cluster

Amazon Managed Service for Prometheus is a monitoring service for metrics compatible with the open source Prometheus project, making it easier for you to securely monitor container environments. AMP is a solution for monitoring containers based on the popular Cloud Native Computing Foundation (CNCF) Prometheus project. Amazon Managed Service for Grafana is a fully managed service with rich, interactive data visualizations to help customers analyze, monitor, and alarm on metrics, logs, and traces across multiple data sources

This document walk-through the process of deploying and configuring an end to end [Amazon Managed Prometheus](https://aws.amazon.com/prometheus/) and [Amazon Managed service for Grafana](https://aws.amazon.com/grafana/) in [Amazon EKS Cluster](https://aws.amazon.com/eks/)

   - Deploy Private VPC, Subnets and all the required VPC endpoints
   - Deploy EKS Cluster with one managed node group in an VPC
   - Deploy [Prometheus Server Helm Chart](https://github.com/prometheus-community/helm-charts) in EKS Cluster
   - Create [Amazon Managed Prometheus Workspace](https://aws.amazon.com/prometheus/) to store the metrics from EKS Cluster
   - Create VPC Endpoints for Amazon Managed Prometheus Workspace to communicate securely from EKS Private subnets
   - Create [Amazon Managed service for Grafana](https://aws.amazon.com/grafana/) Workspace and configure SSO for secure login. NOTE: This step is done through the AWS console 
   - Build Grafana Dashboard for EKS resources with [Amazon Managed Workspace Datasource](https://docs.aws.amazon.com/grafana/latest/userguide/prometheus-data-source.html)
   - Add Amazon Managed Prometheus data source to Grafana and query the metrics


# Architecture
At a high-level, This solution creates a fully managed Amazon Managed Prometheus(AMP) Workspace with all the necessary IAM roles and deploys the Prometheus community edition Helm chart in EKS Cluster to remotely push the cluster metrics to [Amazon Managed Prometheus Workspace(AMP)](https://aws.amazon.com/prometheus/). Amazon Managed Prometheus Workspace(AMP) workspace is exposed as a Datasource for AWS Managed Grafana and it allows you to quickly build the Dashboards. Fully private EKS Clusters securely communicates with [Amazon Managed Prometheus(AMP)](https://aws.amazon.com/prometheus/) using AMP VPC Endpoint without having to leave the network. 

[Amazon Managed Grafana with SSO configuration](https://aws.amazon.com/grafana/) helps to create dashboards to visualize and monitor the EKS clusters by connecting to Amazon Managed Prometheus Workspace(AMP) datasource. Administrators and developers can login with their credentials to edit and monitor the Grafana dashboards.

![Alt Text](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/blob/15103e3294cc78af34bc8bd9b5186720065deb5d/images/AWS-AMP-Prometheus-EKS-Design.png "AWS Managed Prometheus and Managed Grafana Architecture") 


## Deploying the Solution

### Step1 - Install Prerequisites 

[Install Prerequisites](https://github.com/aws-samples/aws-eks-accelerator-for-terraform#prerequisites)

### Step2 - Clone the Repo

```bash
   git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git
   cd aws-eks-accelerator-for-terraform
```

### Step3 - Deploy EKS with Terraform

The following steps to creates a local Terraform state for EKS Cluster and deploys EKS Cluster with Amazon Managed Prometheus Workspace. This also creates all the necessary IAM roles, VPC Endpoints for Amazon Managed Prometheus

```bash 

terraform -chdir=source init -backend-config ../live/preprod/eu-west-1/application/dev/backend.conf

terraform -chdir=source plan -var-file ../live/preprod/eu-west-1/application/dev/base.tfvars

terraform -chdir=source apply -var-file ../live/preprod/eu-west-1/application/dev/base.tfvars


```


## Amazon Managed Prometheus Workspace

AMP offers a secure and highly available service that eliminates the need to manually deploy, manage, and operate Prometheus components. The service also seamlessly integrates with the new Amazon Managed Service for Grafana service to simplify data visualization, team management authentication, and authorization. This image shows the output of the AMP workspace created by this solution. 

![Alt Text](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/blob/0432f0afefeb282eb5dc9b4527fc02bef3b53cc5/images/AWS-Managed-Prometheus.png "AWS Managed Prometheus") 

## Amazon Managed Grafana WorkSpace

Amazon Managed Service for Grafana is a fully managed service with rich, interactive data visualizations to help customers analyze, monitor, and alarm on metrics, logs, and traces across multiple data sources. Amazon Managed Service for Grafana integrates with AWS Organizations to discover the AWS accounts and resources in your Organizational Units. This image shows the Grafana workspace created with SSO configuration. 
NOTE: This resource is created using AWS console since Terraform module is not available for this service yet.

![Alt Text](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/blob/0432f0afefeb282eb5dc9b4527fc02bef3b53cc5/images/AWS-Grafana-WorkSpace.png "AWS Managed Service for Grafana") 

## Grafana Dashboard with EKS Resources
The image shows the output of the Grafana Dashboard built using the AMP workspace datasource from this EKS Cluster.

![Alt Text](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/blob/36b535ed1eb220c7dae4cbf6a40c43b6283b87ae/images/AWS-Managed-Grafana.png "AWS Managed Service for Grafana") 

## Prometheus Community Helm Chart Deployment in EKS Cluster

This image shows the Prometheus Community Edition deployment Pod resources

![Alt Text](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/blob/36b535ed1eb220c7dae4cbf6a40c43b6283b87ae/images/EKS-Prometheus-Deployment.png "AWS Prometheus Services") 





