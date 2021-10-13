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

# EKS Addons update

Amazon EKS doesn't modify any of your Kubernetes add-ons when you update a cluster to newer versions.
It's important to upgrade EKS Addons [Amazon VPC CNI](https://github.com/aws/amazon-vpc-cni-k8s), [DNS (CoreDNS)](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html) and [KubeProxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html) for each EKS release.

This [README](eks_cluster_addons_upgrade/README.md) guides you to update the EKS Cluster and the addons for newer versions that matches with your EKS cluster version

Updating a EKS cluster instructions can be found in [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html).