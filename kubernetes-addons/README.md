# Usage

<!--- BEGIN_TF_DOCS --->
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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.66.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.7.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.66.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_agones"></a> [agones](#module\_agones) | ./agones | n/a |
| <a name="module_argocd"></a> [argocd](#module\_argocd) | ./argocd | n/a |
| <a name="module_aws_ebs_csi_driver"></a> [aws\_ebs\_csi\_driver](#module\_aws\_ebs\_csi\_driver) | ./aws-ebs-csi-driver | n/a |
| <a name="module_aws_for_fluent_bit"></a> [aws\_for\_fluent\_bit](#module\_aws\_for\_fluent\_bit) | ./aws-for-fluentbit | n/a |
| <a name="module_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#module\_aws\_load\_balancer\_controller) | ./aws-load-balancer-controller | n/a |
| <a name="module_aws_node_termination_handler"></a> [aws\_node\_termination\_handler](#module\_aws\_node\_termination\_handler) | ./aws-node-termination-handler | n/a |
| <a name="module_aws_opentelemetry_collector"></a> [aws\_opentelemetry\_collector](#module\_aws\_opentelemetry\_collector) | ./aws-opentelemetry-eks | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ./cert-manager | n/a |
| <a name="module_cluster_autoscaler"></a> [cluster\_autoscaler](#module\_cluster\_autoscaler) | ./cluster-autoscaler | n/a |
| <a name="module_coredns"></a> [coredns](#module\_coredns) | ./aws-coredns | n/a |
| <a name="module_fargate_fluentbit"></a> [fargate\_fluentbit](#module\_fargate\_fluentbit) | ./fargate-fluentbit | n/a |
| <a name="module_ingress_nginx"></a> [ingress\_nginx](#module\_ingress\_nginx) | ./ingress-nginx | n/a |
| <a name="module_keda"></a> [keda](#module\_keda) | ./keda | n/a |
| <a name="module_kube_proxy"></a> [kube\_proxy](#module\_kube\_proxy) | ./aws-kube-proxy | n/a |
| <a name="module_metrics_server"></a> [metrics\_server](#module\_metrics\_server) | ./metrics-server | n/a |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | ./prometheus | n/a |
| <a name="module_spark_k8s_operator"></a> [spark\_k8s\_operator](#module\_spark\_k8s\_operator) | ./spark-k8s-operator | n/a |
| <a name="module_traefik_ingress"></a> [traefik\_ingress](#module\_traefik\_ingress) | ./traefik-ingress | n/a |
| <a name="module_vpa"></a> [vpa](#module\_vpa) | ./vertical-pod-autoscaler | n/a |
| <a name="module_vpc_cni"></a> [vpc\_cni](#module\_vpc\_cni) | ./aws-vpc-cni | n/a |
| <a name="module_yunikorn"></a> [yunikorn](#module\_yunikorn) | ./yunikorn | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agones_enable"></a> [agones\_enable](#input\_agones\_enable) | Enabling Agones Gaming Helm Chart | `bool` | `false` | no |
| <a name="input_agones_helm_chart"></a> [agones\_helm\_chart](#input\_agones\_helm\_chart) | Agones GameServer Helm chart config | `any` | `{}` | no |
| <a name="input_application_teams"></a> [application\_teams](#input\_application\_teams) | Map of maps of Application Teams to create | `any` | `{}` | no |
| <a name="input_argocd_applications"></a> [argocd\_applications](#input\_argocd\_applications) | ARGO CD Applications config to bootstrap the cluster | `any` | `{}` | no |
| <a name="input_argocd_enable"></a> [argocd\_enable](#input\_argocd\_enable) | Enable ARGO CD Kubernetes Addon | `bool` | `false` | no |
| <a name="input_argocd_helm_chart"></a> [argocd\_helm\_chart](#input\_argocd\_helm\_chart) | ARGO CD Kubernetes Addon Configuration | `any` | `{}` | no |
| <a name="input_argocd_manage_add_ons"></a> [argocd\_manage\_add\_ons](#input\_argocd\_manage\_add\_ons) | Enables managing add-on configuration via ArgoCD | `bool` | `false` | no |
| <a name="input_auto_scaling_group_names"></a> [auto\_scaling\_group\_names](#input\_auto\_scaling\_group\_names) | List of Self Managed Node Groups Autoscaling group names | `list` | `[]` | no |
| <a name="input_aws_for_fluentbit_enable"></a> [aws\_for\_fluentbit\_enable](#input\_aws\_for\_fluentbit\_enable) | Enabling FluentBit Addon on EKS Worker Nodes | `bool` | `false` | no |
| <a name="input_aws_for_fluentbit_helm_chart"></a> [aws\_for\_fluentbit\_helm\_chart](#input\_aws\_for\_fluentbit\_helm\_chart) | Helm chart definition for aws\_for\_fluent\_bit | `any` | `{}` | no |
| <a name="input_aws_lb_ingress_controller_enable"></a> [aws\_lb\_ingress\_controller\_enable](#input\_aws\_lb\_ingress\_controller\_enable) | enabling LB Ingress Controller on eks cluster | `bool` | `false` | no |
| <a name="input_aws_lb_ingress_controller_helm_app"></a> [aws\_lb\_ingress\_controller\_helm\_app](#input\_aws\_lb\_ingress\_controller\_helm\_app) | Helm chart definition for aws\_lb\_ingress\_controller | `any` | `{}` | no |
| <a name="input_aws_managed_prometheus_enable"></a> [aws\_managed\_prometheus\_enable](#input\_aws\_managed\_prometheus\_enable) | Enable AWS Managed Prometheus service | `bool` | `false` | no |
| <a name="input_aws_managed_prometheus_ingest_iam_role_arn"></a> [aws\_managed\_prometheus\_ingest\_iam\_role\_arn](#input\_aws\_managed\_prometheus\_ingest\_iam\_role\_arn) | AWS Managed Prometheus WorkSpaceSpace IAM role ARN | `string` | `""` | no |
| <a name="input_aws_managed_prometheus_ingest_service_account"></a> [aws\_managed\_prometheus\_ingest\_service\_account](#input\_aws\_managed\_prometheus\_ingest\_service\_account) | AWS Managed Prometheus Ingest Service Account | `string` | `""` | no |
| <a name="input_aws_managed_prometheus_workspace_id"></a> [aws\_managed\_prometheus\_workspace\_id](#input\_aws\_managed\_prometheus\_workspace\_id) | AWS Managed Prometheus WorkSpace Name | `string` | `""` | no |
| <a name="input_aws_node_termination_handler_enable"></a> [aws\_node\_termination\_handler\_enable](#input\_aws\_node\_termination\_handler\_enable) | Enabling AWS Node Termination Handler | `bool` | `false` | no |
| <a name="input_aws_node_termination_handler_helm_chart"></a> [aws\_node\_termination\_handler\_helm\_chart](#input\_aws\_node\_termination\_handler\_helm\_chart) | Helm chart definition for aws\_node\_termination\_handler | `any` | `{}` | no |
| <a name="input_aws_open_telemetry_addon"></a> [aws\_open\_telemetry\_addon](#input\_aws\_open\_telemetry\_addon) | AWS Open Telemetry Distro Addon Configuration | `any` | `{}` | no |
| <a name="input_aws_open_telemetry_enable"></a> [aws\_open\_telemetry\_enable](#input\_aws\_open\_telemetry\_enable) | Enable AWS Open Telemetry Distro Addon | `bool` | `false` | no |
| <a name="input_cert_manager_enable"></a> [cert\_manager\_enable](#input\_cert\_manager\_enable) | Enabling Cert Manager Helm Chart installation. | `bool` | `false` | no |
| <a name="input_cert_manager_helm_chart"></a> [cert\_manager\_helm\_chart](#input\_cert\_manager\_helm\_chart) | Cert Manager Helm chart configuration | `any` | `{}` | no |
| <a name="input_cluster_autoscaler_enable"></a> [cluster\_autoscaler\_enable](#input\_cluster\_autoscaler\_enable) | Enabling Cluster autoscaler on eks cluster | `bool` | `false` | no |
| <a name="input_cluster_autoscaler_helm_chart"></a> [cluster\_autoscaler\_helm\_chart](#input\_cluster\_autoscaler\_helm\_chart) | Cluster Autoscaler Helm Chart Config | `any` | `{}` | no |
| <a name="input_eks_addon_aws_ebs_csi_driver_config"></a> [eks\_addon\_aws\_ebs\_csi\_driver\_config](#input\_eks\_addon\_aws\_ebs\_csi\_driver\_config) | Map of Amazon EKS aws\_ebs\_csi\_driver Add-on | `any` | `{}` | no |
| <a name="input_eks_addon_coredns_config"></a> [eks\_addon\_coredns\_config](#input\_eks\_addon\_coredns\_config) | Map of Amazon COREDNS EKS Add-on | `any` | `{}` | no |
| <a name="input_eks_addon_kube_proxy_config"></a> [eks\_addon\_kube\_proxy\_config](#input\_eks\_addon\_kube\_proxy\_config) | Map of Amazon EKS KUBE\_PROXY Add-on | `any` | `{}` | no |
| <a name="input_eks_addon_vpc_cni_config"></a> [eks\_addon\_vpc\_cni\_config](#input\_eks\_addon\_vpc\_cni\_config) | Map of Amazon EKS VPC CNI Add-on | `any` | `{}` | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster ID | `any` | n/a | yes |
| <a name="input_eks_cluster_oidc_url"></a> [eks\_cluster\_oidc\_url](#input\_eks\_cluster\_oidc\_url) | The URL on the EKS cluster OIDC Issuer | `string` | `""` | no |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | The ARN of the OIDC Provider if `enable_irsa = true`. | `string` | `""` | no |
| <a name="input_eks_worker_security_group_id"></a> [eks\_worker\_security\_group\_id](#input\_eks\_worker\_security\_group\_id) | EKS Worker Security group ID created by EKS module | `string` | `""` | no |
| <a name="input_enable_eks_addon_aws_ebs_csi_driver"></a> [enable\_eks\_addon\_aws\_ebs\_csi\_driver](#input\_enable\_eks\_addon\_aws\_ebs\_csi\_driver) | Enable EKS Managed EBS CSI Driver Addon | `bool` | `false` | no |
| <a name="input_enable_eks_addon_coredns"></a> [enable\_eks\_addon\_coredns](#input\_enable\_eks\_addon\_coredns) | Enable CoreDNS Addon | `bool` | `false` | no |
| <a name="input_enable_eks_addon_kube_proxy"></a> [enable\_eks\_addon\_kube\_proxy](#input\_enable\_eks\_addon\_kube\_proxy) | Enable Kube Proxy Addon | `bool` | `false` | no |
| <a name="input_enable_eks_addon_vpc_cni"></a> [enable\_eks\_addon\_vpc\_cni](#input\_enable\_eks\_addon\_vpc\_cni) | Enable VPC CNI Addon | `bool` | `false` | no |
| <a name="input_fargate_fluentbit_config"></a> [fargate\_fluentbit\_config](#input\_fargate\_fluentbit\_config) | Fargate fluentbit configuration | `any` | `{}` | no |
| <a name="input_fargate_fluentbit_enable"></a> [fargate\_fluentbit\_enable](#input\_fargate\_fluentbit\_enable) | Enabling fargate\_fluent\_bit module on eks cluster | `bool` | `false` | no |
| <a name="input_ingress_nginx_controller_enable"></a> [ingress\_nginx\_controller\_enable](#input\_ingress\_nginx\_controller\_enable) | Enabling NGINX Ingress Controller on EKS Cluster | `bool` | `false` | no |
| <a name="input_keda_create_irsa"></a> [keda\_create\_irsa](#input\_keda\_create\_irsa) | Indicates if the add-on should create a IAM role + service account | `bool` | `true` | no |
| <a name="input_keda_enable"></a> [keda\_enable](#input\_keda\_enable) | Enable KEDA Event-based autoscaler for workloads on Kubernetes | `bool` | `false` | no |
| <a name="input_keda_helm_chart"></a> [keda\_helm\_chart](#input\_keda\_helm\_chart) | KEDA Event-based autoscaler Kubernetes Addon Configuration | `any` | `{}` | no |
| <a name="input_keda_irsa_policies"></a> [keda\_irsa\_policies](#input\_keda\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_metrics_server_enable"></a> [metrics\_server\_enable](#input\_metrics\_server\_enable) | Enabling metrics server on eks cluster | `bool` | `false` | no |
| <a name="input_metrics_server_helm_chart"></a> [metrics\_server\_helm\_chart](#input\_metrics\_server\_helm\_chart) | Metrics Server Helm Addon Config | `any` | `{}` | no |
| <a name="input_nginx_helm_chart"></a> [nginx\_helm\_chart](#input\_nginx\_helm\_chart) | NGINX Ingress Controller Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_node_groups_iam_role_arn"></a> [node\_groups\_iam\_role\_arn](#input\_node\_groups\_iam\_role\_arn) | n/a | `list(string)` | `[]` | no |
| <a name="input_platform_teams"></a> [platform\_teams](#input\_platform\_teams) | Map of maps of platform teams to create | `any` | `{}` | no |
| <a name="input_prometheus_enable"></a> [prometheus\_enable](#input\_prometheus\_enable) | Enable Community Prometheus Helm Addon | `bool` | `false` | no |
| <a name="input_prometheus_helm_chart"></a> [prometheus\_helm\_chart](#input\_prometheus\_helm\_chart) | Community Prometheus Helm Addon Config | `any` | `{}` | no |
| <a name="input_spark_on_k8s_operator_enable"></a> [spark\_on\_k8s\_operator\_enable](#input\_spark\_on\_k8s\_operator\_enable) | Enabling Spark on K8s Operator on EKS Cluster | `bool` | `false` | no |
| <a name="input_spark_on_k8s_operator_helm_chart"></a> [spark\_on\_k8s\_operator\_helm\_chart](#input\_spark\_on\_k8s\_operator\_helm\_chart) | Spark on K8s Operator Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_traefik_helm_chart"></a> [traefik\_helm\_chart](#input\_traefik\_helm\_chart) | Traefik Helm Addon Config | `any` | `{}` | no |
| <a name="input_traefik_ingress_controller_enable"></a> [traefik\_ingress\_controller\_enable](#input\_traefik\_ingress\_controller\_enable) | Enabling Traefik Ingress Controller on eks cluster | `bool` | `false` | no |
| <a name="input_vpa_enable"></a> [vpa\_enable](#input\_vpa\_enable) | Enable Kubernetes Vertical Pod Autoscaler | `bool` | `false` | no |
| <a name="input_vpa_helm_chart"></a> [vpa\_helm\_chart](#input\_vpa\_helm\_chart) | Kubernetes Vertical Pod Autoscaler Helm chart config | `any` | `{}` | no |
| <a name="input_yunikorn_enable"></a> [yunikorn\_enable](#input\_yunikorn\_enable) | Enable Apache YuniKorn K8s scheduler | `bool` | `false` | no |
| <a name="input_yunikorn_helm_chart"></a> [yunikorn\_helm\_chart](#input\_yunikorn\_helm\_chart) | YuniKorn K8s scheduler Helm chart config | `any` | `{}` | no |

## Outputs

No outputs.

<!--- END_TF_DOCS --->

