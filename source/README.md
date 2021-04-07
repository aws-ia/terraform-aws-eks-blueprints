## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.34.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.0.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.0.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.34.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 14.0.0 |
| <a name="module_eks-label"></a> [eks-label](#module\_eks-label) | ../modules/aws-resource-label |  |
| <a name="module_helm"></a> [helm](#module\_helm) | ../helm |  |
| <a name="module_iam"></a> [iam](#module\_iam) | ../modules/iam |  |
| <a name="module_launch-templates-on-demand"></a> [launch-templates-on-demand](#module\_launch-templates-on-demand) | ../modules/launch-templates |  |
| <a name="module_launch-templates-spot"></a> [launch-templates-spot](#module\_launch-templates-spot) | ../modules/launch-templates |  |
| <a name="module_rbac"></a> [rbac](#module\_rbac) | ../modules/rbac |  |
| <a name="module_s3"></a> [s3](#module\_s3) | ../modules/s3 |  |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws |  |
| <a name="module_vpc-label"></a> [vpc-label](#module\_vpc-label) | ../modules/aws-resource-label |  |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/3.34.0/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/3.34.0/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/3.34.0/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/3.34.0/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/3.34.0/docs/data-sources/region) | data source |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/3.34.0/docs/data-sources/security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `string` | `""` | no |
| <a name="input_aws_for_fluent_bit_enable"></a> [aws\_for\_fluent\_bit\_enable](#input\_aws\_for\_fluent\_bit\_enable) | Enabling aws\_fluent\_bit module on eks cluster | `bool` | `false` | no |
| <a name="input_cluster_autoscaler_enable"></a> [cluster\_autoscaler\_enable](#input\_cluster\_autoscaler\_enable) | enabling metrics server on eks cluster | `bool` | `true` | no |
| <a name="input_cluster_log_retention_period"></a> [cluster\_log\_retention\_period](#input\_cluster\_log\_retention\_period) | Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. | `number` | `7` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Controls if VPC should be created (it affects almost all resources) | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `name`, `tenant`, `zone`, etc. | `string` | `"-"` | no |
| <a name="input_ekslog_retention_in_days"></a> [ekslog\_retention\_in\_days](#input\_ekslog\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true | `bool` | `true` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`] | `list(string)` | `[]` | no |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | `"preprod"` | no |
| <a name="input_fargate_profile_namespace"></a> [fargate\_profile\_namespace](#input\_fargate\_profile\_namespace) | AWS fargate profile name | `string` | `"default"` | no |
| <a name="input_kubernetes_labels"></a> [kubernetes\_labels](#input\_kubernetes\_labels) | Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed | `map(string)` | `{}` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Desired Kubernetes master version. If you do not specify a value, the latest available version is used | `string` | `"1.19"` | no |
| <a name="input_map_additional_aws_accounts"></a> [map\_additional\_aws\_accounts](#input\_map\_additional\_aws\_accounts) | Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap | `list(string)` | `[]` | no |
| <a name="input_map_additional_iam_roles"></a> [map\_additional\_iam\_roles](#input\_map\_additional\_iam\_roles) | Additional IAM roles to add to `config-map-aws-auth` ConfigMap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_additional_iam_users"></a> [map\_additional\_iam\_users](#input\_map\_additional\_iam\_users) | Additional IAM users to add to `config-map-aws-auth` ConfigMap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_metrics_server_enable"></a> [metrics\_server\_enable](#input\_metrics\_server\_enable) | enabling metrics server on eks cluster | `bool` | `true` | no |
| <a name="input_on_demand_ami_type"></a> [on\_demand\_ami\_type](#input\_on\_demand\_ami\_type) | AWS eks managed worker nodes AMI type | `string` | `"AL2_x86_64"` | no |
| <a name="input_on_demand_desired_size"></a> [on\_demand\_desired\_size](#input\_on\_demand\_desired\_size) | Desired number of worker nodes | `number` | `3` | no |
| <a name="input_on_demand_disk_size"></a> [on\_demand\_disk\_size](#input\_on\_demand\_disk\_size) | Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided | `number` | `50` | no |
| <a name="input_on_demand_instance_type"></a> [on\_demand\_instance\_type](#input\_on\_demand\_instance\_type) | Set of instance types associated with the EKS Node Group | `list(string)` | <pre>[<br>  "m5.large"<br>]</pre> | no |
| <a name="input_on_demand_max_size"></a> [on\_demand\_max\_size](#input\_on\_demand\_max\_size) | The maximum size of the AutoScaling Group | `number` | `3` | no |
| <a name="input_on_demand_min_size"></a> [on\_demand\_min\_size](#input\_on\_demand\_min\_size) | The minimum size of the AutoScaling Group | `number` | `1` | no |
| <a name="input_on_demand_node_group_name"></a> [on\_demand\_node\_group\_name](#input\_on\_demand\_node\_group\_name) | AWS eks managed node group name | `string` | `"mg-m5-on-demand"` | no |
| <a name="input_org"></a> [org](#input\_org) | tenant, which could be your organization name, e.g. aws' | `string` | `""` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | list of private subnets Id's for the Worker nodes | `list` | `[]` | no |
| <a name="input_private_subnets_cidr"></a> [private\_subnets\_cidr](#input\_private\_subnets\_cidr) | list of subnets for the Worker nodes | `list` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | list of private subnets Id's for the Worker nodes | `list` | `[]` | no |
| <a name="input_public_subnets_cidr"></a> [public\_subnets\_cidr](#input\_public\_subnets\_cidr) | list of subnets for the Worker nodes | `list` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"eu-west-1"` | no |
| <a name="input_spot_ami_type"></a> [spot\_ami\_type](#input\_spot\_ami\_type) | AWS eks managed worker nodes AMI type | `string` | `"AL2_x86_64"` | no |
| <a name="input_spot_desired_size"></a> [spot\_desired\_size](#input\_spot\_desired\_size) | Desired number of worker nodes | `number` | `3` | no |
| <a name="input_spot_instance_type"></a> [spot\_instance\_type](#input\_spot\_instance\_type) | Set of instance types associated with the EKS Node Group. Defaults to ["t3.medium"]. Terraform will only perform drift detection if a configuration value is provided | `list(string)` | <pre>[<br>  "m5.large"<br>]</pre> | no |
| <a name="input_spot_max_size"></a> [spot\_max\_size](#input\_spot\_max\_size) | The maximum size of the AutoScaling Group | `number` | `3` | no |
| <a name="input_spot_min_size"></a> [spot\_min\_size](#input\_spot\_min\_size) | The minimum size of the AutoScaling Group | `number` | `1` | no |
| <a name="input_spot_node_group_name"></a> [spot\_node\_group\_name](#input\_spot\_node\_group\_name) | AWS eks managed node group for spot | `string` | `"mg-m5-spot"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | `""` | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Terraform Version | `string` | `"Terraform"` | no |
| <a name="input_traefik_ingress_controller_enable"></a> [traefik\_enable](#input\_traefik\_enable) | enabling Traefik Ingress Controller on eks cluster | `bool` | `false` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC CIDR | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id | `string` | `""` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS control plane. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Kubernetes Cluster Name |
