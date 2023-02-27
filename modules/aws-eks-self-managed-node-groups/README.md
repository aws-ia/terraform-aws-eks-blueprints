# AWS Self-Managed Node Groups

# Introduction

Amazon EKS Self Managed Node Groups lets you create, update, scale, and terminate worker nodes for your EKS cluster. All Self managed nodes are provisioned as part of an Amazon EC2 Auto Scaling group that's managed for you by this module. Moreover, all resources including Amazon EC2 instances and Auto Scaling groups run within your AWS account.

This module allows you to create on-demand or spot self managed Linux or Windows nodegroups. You can instantiate the module once with map of node group values to create multiple self managed node groups. By default, the module uses the latest available version of Amazon-provided EKS-optimized AMIs for Amazon Linux 2, Bottlerocket, or Windows 2019 Server Core operating systems. You can override the image via the custom_ami_id input variable.

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_launch_template_self_managed_ng"></a> [launch\_template\_self\_managed\_ng](#module\_launch\_template\_self\_managed\_ng) | ../launch-templates | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.self_managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_iam_instance_profile.self_managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.eks_windows_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.self_managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks_windows_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.self_managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_ami.predefined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.eks_windows_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.self_managed_ng_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Input configuration for the Node groups | <pre>object({<br>    # EKS Cluster Config<br>    eks_cluster_id    = string<br>    cluster_ca_base64 = string<br>    cluster_endpoint  = string<br>    cluster_version   = string<br>    # VPC Config<br>    vpc_id             = string<br>    private_subnet_ids = list(string)<br>    public_subnet_ids  = list(string)<br>    # Security Groups<br>    worker_security_group_ids = list(string)<br>    # Data sources<br>    aws_partition_dns_suffix = string<br>    aws_partition_id         = string<br><br>    iam_role_path                 = string<br>    iam_role_permissions_boundary = string<br>    # Tags<br>    tags = map(string)<br>    # Service IPV4/IPV6 CIDR<br>    service_ipv6_cidr = string<br>    service_ipv4_cidr = string<br>  })</pre> | n/a | yes |
| <a name="input_self_managed_ng"></a> [self\_managed\_ng](#input\_self\_managed\_ng) | Map of maps of `eks_self_managed_node_groups` to create | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | Launch Template ARNs for EKS Self Managed Node Group |
| <a name="output_launch_template_ids"></a> [launch\_template\_ids](#output\_launch\_template\_ids) | Launch Template IDs for EKS Self Managed Node Group |
| <a name="output_launch_template_latest_versions"></a> [launch\_template\_latest\_versions](#output\_launch\_template\_latest\_versions) | Launch Template latest versions for EKS Self Managed Node Group |
| <a name="output_self_managed_asg_names"></a> [self\_managed\_asg\_names](#output\_self\_managed\_asg\_names) | Self managed group ASG names |
| <a name="output_self_managed_iam_role_name"></a> [self\_managed\_iam\_role\_name](#output\_self\_managed\_iam\_role\_name) | Self managed groups IAM role names |
| <a name="output_self_managed_nodegroup_iam_instance_profile_arn"></a> [self\_managed\_nodegroup\_iam\_instance\_profile\_arn](#output\_self\_managed\_nodegroup\_iam\_instance\_profile\_arn) | IAM Instance Profile and for EKS Self Managed Node Group |
| <a name="output_self_managed_nodegroup_iam_instance_profile_id"></a> [self\_managed\_nodegroup\_iam\_instance\_profile\_id](#output\_self\_managed\_nodegroup\_iam\_instance\_profile\_id) | IAM Instance Profile ID for EKS Self Managed Node Group |
| <a name="output_self_managed_nodegroup_iam_role_arns"></a> [self\_managed\_nodegroup\_iam\_role\_arns](#output\_self\_managed\_nodegroup\_iam\_role\_arns) | Self managed groups IAM role arns |
| <a name="output_self_managed_nodegroup_name"></a> [self\_managed\_nodegroup\_name](#output\_self\_managed\_nodegroup\_name) | EKS Self Managed node group id |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
