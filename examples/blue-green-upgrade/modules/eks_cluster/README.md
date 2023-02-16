# EKS Blueprint cluster deployment module

## Table of content

- [EKS Blueprint cluster deployment module](#eks-blueprint-cluster-deployment-module)
  - [Table of content](#table-of-content)
  - [Folder overview](#folder-overview)
  - [Infrastructure](#infrastructure)
  - [Infrastructure Architecture](#infrastructure-architecture)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage)
  - [Cleanup](#cleanup)
- [Terraform Doc](#terraform-doc)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

## Folder overview

This folder contains Terraform code to deploy an EKS Blueprint configured to deploy workload with ArgoCD and associated workload repository.
This cluster will be used as part of our demo defined in [principal Readme](../README.md).
What is include in this EKS cluster

## Infrastructure

The AWS resources created by the script are detailed bellow:

- The infrastructure will be deployed in the resources created in the [core-infra stack](../core-infra/README.md)
- EKS Cluster
  - Create an EKS Managed Node Group
  - Create a platform team
  - Create applications teams (with dedicated teams quotas)
    - team-burnham
    - team-riker
    - ecsdemo-frontend
    - ecsdemo-nodejs
    - ecsdemo-crystal
  - Kubernetes addon deployed with Terraform
    - [ArgoCD](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/add-ons/argocd/)
      - to deploy additional addons
      - to deploy our demo workloads
      - configured to be exposed through a service loadbalancer (for testing)
  - [EKS Managed Add-ons](https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/managed-add-ons/)
    - CoreDNS
    - Kube Proxy
    - VPC CNI
    - EBS CSI Driver
  - Kubernetes addon deployed half with terraform and half with dedicated [ArgoCD addon repo](https://github.com/aws-samples/eks-blueprints-add-ons)
    - [Metrics server](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/add-ons/metrics-server/)
    - [Vertical Pod Autoscaler](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/add-ons/vpa/)
    - [Aws Load Balancer Controller](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/add-ons/aws-load-balancer-controller/)
    - [Karpenter](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/add-ons/karpenter/)
    - [External DNS](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/add-ons/external-dns/)
      - configured to target core infra Hosted Zone
    - [AWS for FluentBit](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/add-ons/aws-for-fluent-bit/) to centralized logs in Amazon CloudWatch
    - [AWS CloudWatch Metrics](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/add-ons/aws-cloudwatch-metrics/) to enable [Container Insight](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html)
    - [Kubecost](https://aws-ia.github.io/terraform-aws-eks-blueprints/main/add-ons/kubecost/)
  - Kubernetes workloads (defined in a dedicated github repository repository)
    - team-burnham
      - burnham-ingress configured with weighted target groups

## Infrastructure Architecture

The following diagram represents the Infrastructure architecture being deployed with this project:

<p align="center">
  <img src="../static/archi-blue-green.png"/>
</p>

## Prerequisites

- Before launching this solution please deploy the `core-infra` solution, which is provided in the root of this repository.
- A public AWS Route 53 Hosted Zone that will be used to create our project hosted zone. It will be provided wviathe Terraform variable `"hosted_zone_name`
  - Before moving to the next step, you will need to register a parent domain with AWS Route 53 (https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html) in case you don’t have one created yet.
- Accessing GitOps Private git repositories with SSH access requiring an SSH key for authentication. In this example our workloads repositories are stored in GitHub, you can see in GitHub documentation on how to [connect with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).
  - The private ssh key value are supposed to be stored in AWS Secret Manager, by default in a secret named `github-blueprint-ssh-key`, but you can change it using the terraform variable `workload_repo_secret`

## Usage

**1.** Run Terraform init to download the providers and install the modules

```shell
terraform init
```

**2.** Create your SSH Key in Secret Manager

Retrieve the ArgoUI password

```bash
aws secretsmanager get-secret-value \
  --secret-id github-blueprint-ssh-key \
  --query SecretString \
  --output text --region $AWS_REGION
```
Should output your private key
```
-----PLACEHOLDER OPENSSH PRIVATE KEY-----
FAKEKEY==
-----END OPENSSH PRIVATE KEY-----
```


**3.** Review the terraform plan output, take a look at the changes that terraform will execute, and then apply them:

```shell
terraform plan
terraform apply
```

**4.** Once Terraform finishes the deployment open the ArgoUI Management Console And authenticate with the secret created by the core_infra stack

Retrieve the ArgoUI password

```bash
aws secretsmanager get-secret-value \
  --secret-id argocd-admin-secret.eks-blueprint \
  --query SecretString \
  --output text --region $AWS_REGION
```

Connect to the ArgoUI endpoint:

```bash
echo -n "https://"; kubectl get svc -n argocd argo-cd-argocd-server -o json | jq ".status.loadBalancer.ingress[0].hostname" -r
```

Validate the certificate issue, and login with credentials admin / <previous password from secretsmanager>

**5.** Control Access to the Burnham ingress

```bash
URL=$(echo -n "https://" ; kubectl get ing -n team-burnham burnham-ingress -o json | jq ".spec.rules[0].host" -r)
curl -s $URL | grep CLUSTER_NAME | awk -F "<span>|</span>" '{print $4}'
```

## Cleanup

See Cleanup section in main Readme.md
