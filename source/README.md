<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: MIT-0

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.48.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.48.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-eks-addon"></a> [aws-eks-addon](#module\_aws-eks-addon) | ../modules/aws-eks-addon | n/a |
| <a name="module_aws_managed_prometheus"></a> [aws\_managed\_prometheus](#module\_aws\_managed\_prometheus) | ../modules/aws_managed_prometheus | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 17.1.0 |
| <a name="module_eks-label"></a> [eks-label](#module\_eks-label) | ../modules/aws-resource-label | n/a |
| <a name="module_endpoints_interface"></a> [endpoints\_interface](#module\_endpoints\_interface) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | v3.2.0 |
| <a name="module_helm"></a> [helm](#module\_helm) | ../helm | n/a |
| <a name="module_iam"></a> [iam](#module\_iam) | ../modules/iam | n/a |
| <a name="module_launch-templates-bottlerocket"></a> [launch-templates-bottlerocket](#module\_launch-templates-bottlerocket) | ../modules/launch-templates | n/a |
| <a name="module_launch-templates-on-demand"></a> [launch-templates-on-demand](#module\_launch-templates-on-demand) | ../modules/launch-templates | n/a |
| <a name="module_launch-templates-spot"></a> [launch-templates-spot](#module\_launch-templates-spot) | ../modules/launch-templates | n/a |
| <a name="module_public-launch-templates-on-demand"></a> [public-launch-templates-on-demand](#module\_public-launch-templates-on-demand) | ../modules/launch-templates | n/a |
| <a name="module_rbac"></a> [rbac](#module\_rbac) | ../modules/rbac | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | ../modules/s3 | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | v3.2.0 |
| <a name="module_vpc-label"></a> [vpc-label](#module\_vpc-label) | ../modules/aws-resource-label | n/a |
| <a name="module_vpc_endpoints_gateway"></a> [vpc\_endpoints\_gateway](#module\_vpc\_endpoints\_gateway) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | v3.2.0 |
| <a name="module_windows_support_iam"></a> [windows\_support\_iam](#module\_windows\_support\_iam) | ../modules/windows-support/iam | n/a |
| <a name="module_windows_support_vpc_resources"></a> [windows\_support\_vpc\_resources](#module\_windows\_support\_vpc\_resources) | ../modules/windows-support/vpc-resources | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/3.48.0/docs/resources/kms_key) | resource |
| [aws_ami.amazonlinux2eks](https://registry.terraform.io/providers/hashicorp/aws/3.48.0/docs/data-sources/ami) | data source |
| [aws_ami.bottlerocket](https://registry.terraform.io/providers/hashicorp/aws/3.48.0/docs/data-sources/ami) | data source |
| [aws_ami.windows2019core](https://registry.terraform.io/providers/hashicorp/aws/3.48.0/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/3.48.0/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/3.48.0/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/3.48.0/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/3.48.0/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/3.48.0/docs/data-sources/region) | data source |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/3.48.0/docs/data-sources/security_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agones_enable"></a> [agones\_enable](#input\_agones\_enable) | Enabling Agones Gaming Helm Chart | `bool` | `false` | no |
| <a name="input_alert_manager_image_tag"></a> [alert\_manager\_image\_tag](#input\_alert\_manager\_image\_tag) | n/a | `string` | `"v0.21.0"` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `string` | `""` | no |
| <a name="input_aws_for_fluent_bit_enable"></a> [aws\_for\_fluent\_bit\_enable](#input\_aws\_for\_fluent\_bit\_enable) | Enabling aws\_fluent\_bit module on eks cluster | `bool` | `false` | no |
| <a name="input_aws_for_fluent_bit_helm_chart_version"></a> [aws\_for\_fluent\_bit\_helm\_chart\_version](#input\_aws\_for\_fluent\_bit\_helm\_chart\_version) | Helm chart version for aws\_for\_fluent\_bit | `string` | `"0.1.11"` | no |
| <a name="input_aws_for_fluent_bit_image_tag"></a> [aws\_for\_fluent\_bit\_image\_tag](#input\_aws\_for\_fluent\_bit\_image\_tag) | Docker image tag for aws\_for\_fluent\_bit | `string` | `"2.13.0"` | no |
| <a name="input_aws_lb_helm_chart_version"></a> [aws\_lb\_helm\_chart\_version](#input\_aws\_lb\_helm\_chart\_version) | n/a | `string` | `"1.2.3"` | no |
| <a name="input_aws_lb_image_tag"></a> [aws\_lb\_image\_tag](#input\_aws\_lb\_image\_tag) | n/a | `string` | `"v2.2.1"` | no |
| <a name="input_aws_managed_prometheus_enable"></a> [aws\_managed\_prometheus\_enable](#input\_aws\_managed\_prometheus\_enable) | n/a | `bool` | `false` | no |
| <a name="input_bottlerocket_ami"></a> [bottlerocket\_ami](#input\_bottlerocket\_ami) | /aws/service/bottlerocket/aws-k8s-1.20/x86\_64/latest/image\_id | `string` | `"ami-0326716ad575410ab"` | no |
| <a name="input_bottlerocket_desired_size"></a> [bottlerocket\_desired\_size](#input\_bottlerocket\_desired\_size) | Desired number of worker nodes | `number` | `3` | no |
| <a name="input_bottlerocket_disk_size"></a> [bottlerocket\_disk\_size](#input\_bottlerocket\_disk\_size) | Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided | `number` | `50` | no |
| <a name="input_bottlerocket_instance_type"></a> [bottlerocket\_instance\_type](#input\_bottlerocket\_instance\_type) | Set of instance types associated with the EKS Node Group | `list(string)` | <pre>[<br>  "m5.large"<br>]</pre> | no |
| <a name="input_bottlerocket_max_size"></a> [bottlerocket\_max\_size](#input\_bottlerocket\_max\_size) | The maximum size of the AutoScaling Group | `number` | `3` | no |
| <a name="input_bottlerocket_min_size"></a> [bottlerocket\_min\_size](#input\_bottlerocket\_min\_size) | The minimum size of the AutoScaling Group | `number` | `3` | no |
| <a name="input_bottlerocket_node_group_name"></a> [bottlerocket\_node\_group\_name](#input\_bottlerocket\_node\_group\_name) | AWS eks managed node group name | `string` | `"mg-m5-bottlerocket"` | no |
| <a name="input_cluster_autoscaler_enable"></a> [cluster\_autoscaler\_enable](#input\_cluster\_autoscaler\_enable) | Enabling Cluster autoscaler on eks cluster | `bool` | `false` | no |
| <a name="input_cluster_autoscaler_helm_version"></a> [cluster\_autoscaler\_helm\_version](#input\_cluster\_autoscaler\_helm\_version) | n/a | `string` | `"9.9.2"` | no |
| <a name="input_cluster_autoscaler_image_tag"></a> [cluster\_autoscaler\_image\_tag](#input\_cluster\_autoscaler\_image\_tag) | n/a | `string` | `"v1.20.0"` | no |
| <a name="input_cluster_log_retention_period"></a> [cluster\_log\_retention\_period](#input\_cluster\_log\_retention\_period) | Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. | `number` | `7` | no |
| <a name="input_configmap_reload_image_tag"></a> [configmap\_reload\_image\_tag](#input\_configmap\_reload\_image\_tag) | n/a | `string` | `"v0.5.0"` | no |
| <a name="input_coredns_addon_version"></a> [coredns\_addon\_version](#input\_coredns\_addon\_version) | CoreDNS Addon verison | `string` | `"v1.8.3-eksbuild.1"` | no |
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | Create internet gateway in public subnets | `bool` | `false` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Controls if VPC should be created (it affects almost all resources) | `bool` | `false` | no |
| <a name="input_create_vpc_endpoints"></a> [create\_vpc\_endpoints](#input\_create\_vpc\_endpoints) | Create VPC endpoints for Private subnets | `bool` | `false` | no |
| <a name="input_ekslog_retention_in_days"></a> [ekslog\_retention\_in\_days](#input\_ekslog\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| <a name="input_enable_coredns_addon"></a> [enable\_coredns\_addon](#input\_enable\_coredns\_addon) | n/a | `bool` | `false` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true | `bool` | `true` | no |
| <a name="input_enable_kube_proxy_addon"></a> [enable\_kube\_proxy\_addon](#input\_enable\_kube\_proxy\_addon) | n/a | `bool` | `false` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Enable NAT Gateway for public subnets | `bool` | `false` | no |
| <a name="input_enable_private_subnets"></a> [enable\_private\_subnets](#input\_enable\_private\_subnets) | Enable private subnets for EKS Cluster | `bool` | `true` | no |
| <a name="input_enable_public_subnets"></a> [enable\_public\_subnets](#input\_enable\_public\_subnets) | Enable public subnets for EKS Cluster | `bool` | `false` | no |
| <a name="input_enable_self_managed_nodegroups"></a> [enable\_self\_managed\_nodegroups](#input\_enable\_self\_managed\_nodegroups) | Enable self-managed worker groups | `bool` | `false` | no |
| <a name="input_enable_vpc_cni_addon"></a> [enable\_vpc\_cni\_addon](#input\_enable\_vpc\_cni\_addon) | n/a | `bool` | `false` | no |
| <a name="input_enable_windows_support"></a> [enable\_windows\_support](#input\_enable\_windows\_support) | Enable Windows support in the cluster | `bool` | `false` | no |
| <a name="input_enabled_cluster_log_types"></a> [enabled\_cluster\_log\_types](#input\_enabled\_cluster\_log\_types) | A list of the desired control plane logging to enable. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`] | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| <a name="input_endpoint_private_access"></a> [endpoint\_private\_access](#input\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false | `bool` | `true` | no |
| <a name="input_endpoint_public_access"></a> [endpoint\_public\_access](#input\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | `"preprod"` | no |
| <a name="input_expose_udp"></a> [expose\_udp](#input\_expose\_udp) | Enabling Agones Gaming Helm Chart | `bool` | `false` | no |
| <a name="input_fargate_fluent_bit_enable"></a> [fargate\_fluent\_bit\_enable](#input\_fargate\_fluent\_bit\_enable) | Enabling fargate\_fluent\_bit module on eks cluster | `bool` | `false` | no |
| <a name="input_fargate_profile_namespace"></a> [fargate\_profile\_namespace](#input\_fargate\_profile\_namespace) | AWS fargate profile Namespace | `string` | `"default"` | no |
| <a name="input_kube_proxy_addon_version"></a> [kube\_proxy\_addon\_version](#input\_kube\_proxy\_addon\_version) | KubeProxy Addon verison | `string` | `"v1.20.4-eksbuild.2"` | no |
| <a name="input_kubernetes_labels"></a> [kubernetes\_labels](#input\_kubernetes\_labels) | Key-value mapping of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed | `map(string)` | `{}` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Desired Kubernetes master version. If you do not specify a value, the latest available version is used | `string` | `"1.20"` | no |
| <a name="input_lb_ingress_controller_enable"></a> [lb\_ingress\_controller\_enable](#input\_lb\_ingress\_controller\_enable) | enabling LB Ingress Controller on eks cluster | `bool` | `false` | no |
| <a name="input_map_additional_aws_accounts"></a> [map\_additional\_aws\_accounts](#input\_map\_additional\_aws\_accounts) | Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap | `list(string)` | `[]` | no |
| <a name="input_map_additional_iam_roles"></a> [map\_additional\_iam\_roles](#input\_map\_additional\_iam\_roles) | Additional IAM roles to add to `config-map-aws-auth` ConfigMap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_additional_iam_users"></a> [map\_additional\_iam\_users](#input\_map\_additional\_iam\_users) | Additional IAM users to add to `config-map-aws-auth` ConfigMap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_metric_server_helm_chart_version"></a> [metric\_server\_helm\_chart\_version](#input\_metric\_server\_helm\_chart\_version) | n/a | `string` | `"2.12.1"` | no |
| <a name="input_metric_server_image_tag"></a> [metric\_server\_image\_tag](#input\_metric\_server\_image\_tag) | n/a | `string` | `"v0.4.2"` | no |
| <a name="input_metrics_server_enable"></a> [metrics\_server\_enable](#input\_metrics\_server\_enable) | Enabling metrics server on eks cluster | `bool` | `false` | no |
| <a name="input_nginx_helm_chart_version"></a> [nginx\_helm\_chart\_version](#input\_nginx\_helm\_chart\_version) | n/a | `string` | `"3.33.0"` | no |
| <a name="input_nginx_image_tag"></a> [nginx\_image\_tag](#input\_nginx\_image\_tag) | n/a | `string` | `"v0.47.0"` | no |
| <a name="input_nginx_ingress_controller_enable"></a> [nginx\_ingress\_controller\_enable](#input\_nginx\_ingress\_controller\_enable) | enabling Nginx Ingress Controller on eks cluster | `bool` | `false` | no |
| <a name="input_node_exporter_image_tag"></a> [node\_exporter\_image\_tag](#input\_node\_exporter\_image\_tag) | n/a | `string` | `"v1.1.2"` | no |
| <a name="input_on_demand_ami_type"></a> [on\_demand\_ami\_type](#input\_on\_demand\_ami\_type) | AWS eks managed worker nodes AMI type | `string` | `"AL2_x86_64"` | no |
| <a name="input_on_demand_desired_size"></a> [on\_demand\_desired\_size](#input\_on\_demand\_desired\_size) | Desired number of worker nodes | `number` | `3` | no |
| <a name="input_on_demand_disk_size"></a> [on\_demand\_disk\_size](#input\_on\_demand\_disk\_size) | Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided | `number` | `50` | no |
| <a name="input_on_demand_instance_type"></a> [on\_demand\_instance\_type](#input\_on\_demand\_instance\_type) | Set of instance types associated with the EKS Node Group | `list(string)` | <pre>[<br>  "m5.large"<br>]</pre> | no |
| <a name="input_on_demand_max_size"></a> [on\_demand\_max\_size](#input\_on\_demand\_max\_size) | The maximum size of the AutoScaling Group | `number` | `3` | no |
| <a name="input_on_demand_min_size"></a> [on\_demand\_min\_size](#input\_on\_demand\_min\_size) | The minimum size of the AutoScaling Group | `number` | `3` | no |
| <a name="input_on_demand_node_group_name"></a> [on\_demand\_node\_group\_name](#input\_on\_demand\_node\_group\_name) | AWS eks managed node group name | `string` | `"mg-m5-on-demand"` | no |
| <a name="input_opentelemetry_command_name"></a> [opentelemetry\_command\_name](#input\_opentelemetry\_command\_name) | The OpenTelemetry command.name value | `string` | `"otel"` | no |
| <a name="input_opentelemetry_enable"></a> [opentelemetry\_enable](#input\_opentelemetry\_enable) | Enabling opentelemetry module on eks cluster | `bool` | `false` | no |
| <a name="input_opentelemetry_enable_agent_collector"></a> [opentelemetry\_enable\_agent\_collector](#input\_opentelemetry\_enable\_agent\_collector) | Enabling the opentelemetry agent collector on eks cluster | `bool` | `true` | no |
| <a name="input_opentelemetry_enable_autoscaling_standalone_collector"></a> [opentelemetry\_enable\_autoscaling\_standalone\_collector](#input\_opentelemetry\_enable\_autoscaling\_standalone\_collector) | Enabling the autoscaling of the standalone gateway collector on eks cluster | `bool` | `false` | no |
| <a name="input_opentelemetry_enable_container_logs"></a> [opentelemetry\_enable\_container\_logs](#input\_opentelemetry\_enable\_container\_logs) | Whether or not to enable container log collection on the otel agents | `bool` | `false` | no |
| <a name="input_opentelemetry_enable_standalone_collector"></a> [opentelemetry\_enable\_standalone\_collector](#input\_opentelemetry\_enable\_standalone\_collector) | Enabling the opentelemetry standalone gateway collector on eks cluster | `bool` | `false` | no |
| <a name="input_opentelemetry_helm_chart"></a> [opentelemetry\_helm\_chart](#input\_opentelemetry\_helm\_chart) | Helm chart for opentelemetry | `string` | `"open-telemetry/opentelemetry-collector"` | no |
| <a name="input_opentelemetry_helm_chart_version"></a> [opentelemetry\_helm\_chart\_version](#input\_opentelemetry\_helm\_chart\_version) | Helm chart version for opentelemetry | `string` | `"0.5.9"` | no |
| <a name="input_opentelemetry_image"></a> [opentelemetry\_image](#input\_opentelemetry\_image) | Docker image for opentelemetry from open-telemetry | `string` | `"otel/opentelemetry-collector"` | no |
| <a name="input_opentelemetry_image_tag"></a> [opentelemetry\_image\_tag](#input\_opentelemetry\_image\_tag) | Docker image tag for opentelemetry from open-telemetry | `string` | `"0.31.0"` | no |
| <a name="input_opentelemetry_max_standalone_collectors"></a> [opentelemetry\_max\_standalone\_collectors](#input\_opentelemetry\_max\_standalone\_collectors) | The maximum number of opentelemetry standalone gateway collectors to run | `number` | `3` | no |
| <a name="input_opentelemetry_min_standalone_collectors"></a> [opentelemetry\_min\_standalone\_collectors](#input\_opentelemetry\_min\_standalone\_collectors) | The minimum number of opentelemetry standalone gateway collectors to run | `number` | `1` | no |
| <a name="input_org"></a> [org](#input\_org) | tenant, which could be your organization name, e.g. aws' | `string` | `"aws"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | list of private subnets Id's for the Worker nodes | `list` | `[]` | no |
| <a name="input_private_subnets_cidr"></a> [private\_subnets\_cidr](#input\_private\_subnets\_cidr) | list of Private subnets for the Worker nodes | `list` | `[]` | no |
| <a name="input_prometheus_enable"></a> [prometheus\_enable](#input\_prometheus\_enable) | n/a | `bool` | `false` | no |
| <a name="input_prometheus_helm_chart_version"></a> [prometheus\_helm\_chart\_version](#input\_prometheus\_helm\_chart\_version) | n/a | `string` | `"14.4.0"` | no |
| <a name="input_prometheus_image_tag"></a> [prometheus\_image\_tag](#input\_prometheus\_image\_tag) | n/a | `string` | `"v2.26.0"` | no |
| <a name="input_public_docker_repo"></a> [public\_docker\_repo](#input\_public\_docker\_repo) | public docker repo access | `bool` | `true` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | list of private subnets Id's for the Worker nodes | `list` | `[]` | no |
| <a name="input_public_subnets_cidr"></a> [public\_subnets\_cidr](#input\_public\_subnets\_cidr) | list of Public subnets for the Worker nodes | `list` | `[]` | no |
| <a name="input_pushgateway_image_tag"></a> [pushgateway\_image\_tag](#input\_pushgateway\_image\_tag) | n/a | `string` | `"v1.3.1"` | no |
| <a name="input_self_managed_node_ami_id"></a> [self\_managed\_node\_ami\_id](#input\_self\_managed\_node\_ami\_id) | Self-managed worker node custom AMI ID | `string` | `""` | no |
| <a name="input_self_managed_node_desired_size"></a> [self\_managed\_node\_desired\_size](#input\_self\_managed\_node\_desired\_size) | Desired number of worker nodes | `number` | `3` | no |
| <a name="input_self_managed_node_instance_types"></a> [self\_managed\_node\_instance\_types](#input\_self\_managed\_node\_instance\_types) | Set of instance types associated with the EKS Node Group | `list(string)` | <pre>[<br>  "m5.large",<br>  "m5a.large",<br>  "m5n.large"<br>]</pre> | no |
| <a name="input_self_managed_node_max_size"></a> [self\_managed\_node\_max\_size](#input\_self\_managed\_node\_max\_size) | The maximum size of the AutoScaling Group | `number` | `3` | no |
| <a name="input_self_managed_node_min_size"></a> [self\_managed\_node\_min\_size](#input\_self\_managed\_node\_min\_size) | The minimum size of the AutoScaling Group | `number` | `3` | no |
| <a name="input_self_managed_node_userdata_template_extra_params"></a> [self\_managed\_node\_userdata\_template\_extra\_params](#input\_self\_managed\_node\_userdata\_template\_extra\_params) | Self-managed worker node custom userdata template extra parameters | `map(any)` | `{}` | no |
| <a name="input_self_managed_node_userdata_template_file"></a> [self\_managed\_node\_userdata\_template\_file](#input\_self\_managed\_node\_userdata\_template\_file) | Self-managed worker node custom userdata template file path | `string` | `""` | no |
| <a name="input_self_managed_node_volume_size"></a> [self\_managed\_node\_volume\_size](#input\_self\_managed\_node\_volume\_size) | Volume size in GiB for worker nodes. Defaults to 50. Terraform will only perform drift detection if a configuration value is provided | `number` | `50` | no |
| <a name="input_self_managed_nodegroup_name"></a> [self\_managed\_nodegroup\_name](#input\_self\_managed\_nodegroup\_name) | Self-managed worker node group name | `string` | `"ng-linux"` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Create single NAT gateway for all private subnets | `bool` | `true` | no |
| <a name="input_spot_ami_type"></a> [spot\_ami\_type](#input\_spot\_ami\_type) | AWS eks managed worker nodes AMI type | `string` | `"AL2_x86_64"` | no |
| <a name="input_spot_desired_size"></a> [spot\_desired\_size](#input\_spot\_desired\_size) | Desired number of worker nodes | `number` | `3` | no |
| <a name="input_spot_instance_type"></a> [spot\_instance\_type](#input\_spot\_instance\_type) | Set of instance types associated with the EKS Node Group. Defaults to ["t3.medium"]. Terraform will only perform drift detection if a configuration value is provided | `list(string)` | <pre>[<br>  "m5.large"<br>]</pre> | no |
| <a name="input_spot_max_size"></a> [spot\_max\_size](#input\_spot\_max\_size) | The maximum size of the AutoScaling Group | `number` | `3` | no |
| <a name="input_spot_min_size"></a> [spot\_min\_size](#input\_spot\_min\_size) | The minimum size of the AutoScaling Group | `number` | `1` | no |
| <a name="input_spot_node_group_name"></a> [spot\_node\_group\_name](#input\_spot\_node\_group\_name) | AWS eks managed node group for spot | `string` | `"mg-m5-spot"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | `""` | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Terraform Version | `string` | `"Terraform"` | no |
| <a name="input_traefik_helm_chart_version"></a> [traefik\_helm\_chart\_version](#input\_traefik\_helm\_chart\_version) | n/a | `string` | `"10.0.0"` | no |
| <a name="input_traefik_image_tag"></a> [traefik\_image\_tag](#input\_traefik\_image\_tag) | n/a | `string` | `"v2.4.9"` | no |
| <a name="input_traefik_ingress_controller_enable"></a> [traefik\_ingress\_controller\_enable](#input\_traefik\_ingress\_controller\_enable) | Enabling Traefik Ingress Controller on eks cluster | `bool` | `false` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC CIDR | `string` | `""` | no |
| <a name="input_vpc_cni_addon_version"></a> [vpc\_cni\_addon\_version](#input\_vpc\_cni\_addon\_version) | VPC CNI Addon verison | `string` | `"v1.8.0-eksbuild.1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id | `string` | `""` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amp_work_arn"></a> [amp\_work\_arn](#output\_amp\_work\_arn) | n/a |
| <a name="output_amp_work_id"></a> [amp\_work\_id](#output\_amp\_work\_id) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Kubernetes Cluster Name |
| <a name="output_cluster_oidc_url"></a> [cluster\_oidc\_url](#output\_cluster\_oidc\_url) | The URL on the EKS cluster OIDC Issuer |
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider if `enable_irsa = true`. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
