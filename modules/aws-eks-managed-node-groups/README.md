# AWS Managed Node Groups

## Introduction

Amazon EKS Managed Node Groups lets you create, update, scale, and terminate worker nodes for your EKS cluster. All managed nodes are provisioned as part of an Amazon EC2 Auto Scaling group that's managed for you by Amazon EKS. Moreover, all resources including Amazon EC2 instances and Auto Scaling groups run within your AWS account. By default, instances in a managed node group use the latest version of the Amazon EKS optimized Amazon Linux 2 AMI for its cluster's Kubernetes version

This module allows you to create ON-DEMAND, SPOT and BOTTLEROCKET(with custom ami) managed nodegroups. You can instantiate the module once with map of node group values to create multiple node groups.

_NOTE_:

- You can't create managed nodes in an AWS Region where you have AWS Outposts, AWS Wavelength, or AWS Local Zones enabled.
- You can create self-managed nodes in an AWS Region where you have AWS Outposts, AWS Wavelength, or AWS Local Zones enabled
- You should not set to true both `create_launch_template` and `remote_access` or you'll end-up with new managed nodegroups that won't be able to join the cluster.

Checkout the usage docs for Managed Node groups [examples](https://aws-ia.github.io/terraform-aws-eks-blueprints/node-groups/)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_node_group.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_instance_profile.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.managed_node_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_iam_policy_document.managed_ng_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Input configuration for the Node groups | <pre>object({<br>    # EKS Cluster Config<br>    eks_cluster_id    = string<br>    cluster_ca_base64 = string<br>    cluster_endpoint  = string<br>    cluster_version   = string<br>    # VPC Config<br>    vpc_id             = string<br>    private_subnet_ids = list(string)<br>    public_subnet_ids  = list(string)<br>    # Security Groups<br>    worker_security_group_ids = list(string)<br><br>    # Data sources<br>    aws_partition_dns_suffix = string<br>    aws_partition_id         = string<br>    #IAM<br>    iam_role_path                 = string<br>    iam_role_permissions_boundary = string<br>    # Tags<br>    tags = map(string)<br>    # Service IPV4/IPV6 CIDR<br>    service_ipv6_cidr = string<br>    service_ipv4_cidr = string<br>  })</pre> | n/a | yes |
| <a name="input_managed_ng"></a> [managed\_ng](#input\_managed\_ng) | Map of maps of `eks_node_groups` to create | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_nodegroup_arn"></a> [managed\_nodegroup\_arn](#output\_managed\_nodegroup\_arn) | EKS Managed node group id |
| <a name="output_managed_nodegroup_iam_instance_profile_arn"></a> [managed\_nodegroup\_iam\_instance\_profile\_arn](#output\_managed\_nodegroup\_iam\_instance\_profile\_arn) | IAM instance profile arn for EKS Managed Node Group |
| <a name="output_managed_nodegroup_iam_instance_profile_id"></a> [managed\_nodegroup\_iam\_instance\_profile\_id](#output\_managed\_nodegroup\_iam\_instance\_profile\_id) | IAM instance profile id for EKS Managed Node Group |
| <a name="output_managed_nodegroup_iam_role_arn"></a> [managed\_nodegroup\_iam\_role\_arn](#output\_managed\_nodegroup\_iam\_role\_arn) | IAM role ARN for EKS Managed Node Group |
| <a name="output_managed_nodegroup_iam_role_name"></a> [managed\_nodegroup\_iam\_role\_name](#output\_managed\_nodegroup\_iam\_role\_name) | IAM role name for EKS Managed Node Group |
| <a name="output_managed_nodegroup_id"></a> [managed\_nodegroup\_id](#output\_managed\_nodegroup\_id) | EKS Managed node group id |
| <a name="output_managed_nodegroup_launch_template_arn"></a> [managed\_nodegroup\_launch\_template\_arn](#output\_managed\_nodegroup\_launch\_template\_arn) | Launch Template ARN for EKS Managed Node Group |
| <a name="output_managed_nodegroup_launch_template_id"></a> [managed\_nodegroup\_launch\_template\_id](#output\_managed\_nodegroup\_launch\_template\_id) | Launch Template ID for EKS Managed Node Group |
| <a name="output_managed_nodegroup_launch_template_latest_version"></a> [managed\_nodegroup\_launch\_template\_latest\_version](#output\_managed\_nodegroup\_launch\_template\_latest\_version) | Launch Template version for EKS Managed Node Group |
| <a name="output_managed_nodegroup_status"></a> [managed\_nodegroup\_status](#output\_managed\_nodegroup\_status) | EKS Managed Node Group status |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
