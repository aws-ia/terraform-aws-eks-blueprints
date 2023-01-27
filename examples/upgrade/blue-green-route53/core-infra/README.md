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

# Terraform Doc

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 4.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.ns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.sub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_secretsmanager_secret.argocd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.argocd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.argocd](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_route53_zone.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_secret_manager_name_suffix"></a> [argocd\_secret\_manager\_name\_suffix](#input\_argocd\_secret\_manager\_name\_suffix) | Name of secret manager secret for ArgoCD Admin UI Password | `string` | `"argocd-admin-secret"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_core_stack_name"></a> [core\_stack\_name](#input\_core\_stack\_name) | The name of Core Infrastructure stack, feel free to rename it. Used for cluster and VPC names. | `string` | `"eks-blueprint"` | no |
| <a name="input_hosted_zone_name"></a> [hosted\_zone\_name](#input\_hosted\_zone\_name) | Route53 domain for the cluster. | `string` | `"sallaman.people.aws.dev"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_acm_certificate_status"></a> [aws\_acm\_certificate\_status](#output\_aws\_acm\_certificate\_status) | Status of Certificate |
| <a name="output_aws_route53_zone"></a> [aws\_route53\_zone](#output\_aws\_route53\_zone) | The new Route53 Zone |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
