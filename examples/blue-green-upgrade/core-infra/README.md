# Core Infrastructure

## Table of content

- [Core Infrastructure](#core-infrastructure)
  - [Table of content](#table-of-content)
  - [Getting Started](#getting-started)
  - [Usage](#usage)
  - [Outputs](#outputs)
  - [Cleanup](#cleanup)
- [Terraform Doc](#terraform-doc)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs-1)

This folder contains the Terraform code to deploy the core infrastructure for our EKS Cluster **Blue** and **Green**. The AWS resources created by the script are:

- Networking
  - VPC
    - 3 public subnets, 1 per AZ. If a region has less than 3 AZs it will create same number of public subnets as AZs.
    - 3 private subnets, 1 per AZ. If a region has less than 3 AZs it will create same number of private subnets as AZs.
    - 1 NAT Gateway
    - 1 Internet Gateway
    - Associated Route Tables
- 1 Hosted zone to use for our clusters with name `${core_stack_name}.${hosted_zone_name}`
- 1 wildcard certificate for TLS termination associated to our new HostedZone `*.${core_stack_name}.${hosted_zone_name}`
- 1 SecretManager password used to access ArgoCD UI in both EKS clusters.

## Getting Started

Make sure you have all the [prerequisites](../README.md#prerequisites) for your laptop.

<!-->

Fork this repository and [create the GitHub token granting access](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) to this new repository in your account. Store this secret in AWS secrets manager using the aws cli.
-->

## Usage


```bash
cd core-infra/
```

- Run Terraform init to download the providers and install the modules

```shell
terraform init
```

> Note: We share

- Review the terraform plan output, take a look at the changes that terraform will execute, and then apply them:

```shell
terraform plan
```

```shell
terraform apply --auto-approve
```

> There can be somme Warnings due to not declare variables. This is normal and you can ignore them as we share the same `terraform.tfvars` for the 3 projects by using symlinks for a uniq file, and we declare some variables used for the eks-blue and eks-green directory

## Outputs

After the execution of the Terraform code you will get an output with needed IDs and values needed as input for the next Terraform applies.

```shell
terraform output
```

Example:

```
aws_acm_certificate_status = "ISSUED"
aws_route53_zone = "eks-blueprint.eks.mydomain.org"
vpc_id = "vpc-0d649baf641a8071e"
```

We are going to use this core infrastructure to host the EKS Blue and Green clusters.

## Cleanup

Run the following command if you want to delete all the resources created before.

> If you have created EKS blueprints clusters, you'll need to clean those resources first.

```shell
terraform destroy
```
