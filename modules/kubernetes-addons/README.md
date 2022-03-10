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
| <a name="module_argo_rollouts"></a> [argo\_rollouts](#module\_argo\_rollouts) | ./argo-rollouts | n/a |
| <a name="module_argocd"></a> [argocd](#module\_argocd) | ./argocd | n/a |
| <a name="module_aws_coredns"></a> [aws\_coredns](#module\_aws\_coredns) | ./aws-coredns | n/a |
| <a name="module_aws_ebs_csi_driver"></a> [aws\_ebs\_csi\_driver](#module\_aws\_ebs\_csi\_driver) | ./aws-ebs-csi-driver | n/a |
| <a name="module_aws_efs_csi_driver"></a> [aws\_efs\_csi\_driver](#module\_aws\_efs\_csi\_driver) | ./aws-efs-csi-driver | n/a |
| <a name="module_aws_for_fluent_bit"></a> [aws\_for\_fluent\_bit](#module\_aws\_for\_fluent\_bit) | ./aws-for-fluentbit | n/a |
| <a name="module_aws_kube_proxy"></a> [aws\_kube\_proxy](#module\_aws\_kube\_proxy) | ./aws-kube-proxy | n/a |
| <a name="module_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#module\_aws\_load\_balancer\_controller) | ./aws-load-balancer-controller | n/a |
| <a name="module_aws_node_termination_handler"></a> [aws\_node\_termination\_handler](#module\_aws\_node\_termination\_handler) | ./aws-node-termination-handler | n/a |
| <a name="module_aws_vpc_cni"></a> [aws\_vpc\_cni](#module\_aws\_vpc\_cni) | ./aws-vpc-cni | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ./cert-manager | n/a |
| <a name="module_cluster_autoscaler"></a> [cluster\_autoscaler](#module\_cluster\_autoscaler) | ./cluster-autoscaler | n/a |
| <a name="module_crossplane"></a> [crossplane](#module\_crossplane) | ./crossplane | n/a |
| <a name="module_fargate_fluentbit"></a> [fargate\_fluentbit](#module\_fargate\_fluentbit) | ./fargate-fluentbit | n/a |
| <a name="module_ingress_nginx"></a> [ingress\_nginx](#module\_ingress\_nginx) | ./ingress-nginx | n/a |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | ./karpenter | n/a |
| <a name="module_keda"></a> [keda](#module\_keda) | ./keda | n/a |
| <a name="module_kubernetes_dashboard"></a> [kubernetes\_dashboard](#module\_kubernetes\_dashboard) | ./kubernetes-dashboard | n/a |
| <a name="module_metrics_server"></a> [metrics\_server](#module\_metrics\_server) | ./metrics-server | n/a |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | ./prometheus | n/a |
| <a name="module_spark_k8s_operator"></a> [spark\_k8s\_operator](#module\_spark\_k8s\_operator) | ./spark-k8s-operator | n/a |
| <a name="module_traefik"></a> [traefik](#module\_traefik) | ./traefik | n/a |
| <a name="module_vpa"></a> [vpa](#module\_vpa) | ./vpa | n/a |
| <a name="module_yunikorn"></a> [yunikorn](#module\_yunikorn) | ./yunikorn | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agones_helm_config"></a> [agones\_helm\_config](#input\_agones\_helm\_config) | Agones GameServer Helm Chart config | `any` | `{}` | no |
| <a name="input_amazon_eks_aws_ebs_csi_driver_config"></a> [amazon\_eks\_aws\_ebs\_csi\_driver\_config](#input\_amazon\_eks\_aws\_ebs\_csi\_driver\_config) | configMap for AWS EBS CSI Driver add-on | `any` | `{}` | no |
| <a name="input_amazon_eks_coredns_config"></a> [amazon\_eks\_coredns\_config](#input\_amazon\_eks\_coredns\_config) | ConfigMap for Amazon CoreDNS EKS add-on | `any` | `{}` | no |
| <a name="input_amazon_eks_kube_proxy_config"></a> [amazon\_eks\_kube\_proxy\_config](#input\_amazon\_eks\_kube\_proxy\_config) | ConfigMap for Amazon EKS Kube-Proxy add-on | `any` | `{}` | no |
| <a name="input_amazon_eks_vpc_cni_config"></a> [amazon\_eks\_vpc\_cni\_config](#input\_amazon\_eks\_vpc\_cni\_config) | ConfigMap of Amazon EKS VPC CNI add-on | `any` | `{}` | no |
| <a name="input_amazon_prometheus_ingest_iam_role_arn"></a> [amazon\_prometheus\_ingest\_iam\_role\_arn](#input\_amazon\_prometheus\_ingest\_iam\_role\_arn) | AWS Managed Prometheus WorkSpaceSpace IAM role ARN | `string` | `null` | no |
| <a name="input_amazon_prometheus_ingest_service_account"></a> [amazon\_prometheus\_ingest\_service\_account](#input\_amazon\_prometheus\_ingest\_service\_account) | AWS Managed Prometheus Ingest Service Account | `string` | `null` | no |
| <a name="input_amazon_prometheus_workspace_endpoint"></a> [amazon\_prometheus\_workspace\_endpoint](#input\_amazon\_prometheus\_workspace\_endpoint) | AWS Managed Prometheus WorkSpace Endpoint | `string` | `null` | no |
| <a name="input_argo_rollouts_helm_config"></a> [argo\_rollouts\_helm\_config](#input\_argo\_rollouts\_helm\_config) | Argo Rollouts Helm Chart config | `any` | `null` | no |
| <a name="input_argo_rollouts_irsa_permissions_boundary"></a> [argo\_rollouts\_irsa\_permissions\_boundary](#input\_argo\_rollouts\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary | `string` | `""` | no |
| <a name="input_argo_rollouts_irsa_policies"></a> [argo\_rollouts\_irsa\_policies](#input\_argo\_rollouts\_irsa\_policies) | IAM policy ARNs for Argo Rollouts IRSA | `list(string)` | `[]` | no |
| <a name="input_argocd_admin_password_secret_name"></a> [argocd\_admin\_password\_secret\_name](#input\_argocd\_admin\_password\_secret\_name) | Name for a secret stored in AWS Secrets Manager that contains the admin password. | `string` | `""` | no |
| <a name="input_argocd_applications"></a> [argocd\_applications](#input\_argocd\_applications) | Argo CD Applications config to bootstrap the cluster | `any` | `{}` | no |
| <a name="input_argocd_helm_config"></a> [argocd\_helm\_config](#input\_argocd\_helm\_config) | Argo CD Kubernetes add-on config | `any` | `{}` | no |
| <a name="input_argocd_manage_add_ons"></a> [argocd\_manage\_add\_ons](#input\_argocd\_manage\_add\_ons) | Enable managing add-on configuration via ArgoCD | `bool` | `false` | no |
| <a name="input_auto_scaling_group_names"></a> [auto\_scaling\_group\_names](#input\_auto\_scaling\_group\_names) | List of self-managed node groups autoscaling group names | `list(string)` | `[]` | no |
| <a name="input_aws_efs_csi_driver_helm_config"></a> [aws\_efs\_csi\_driver\_helm\_config](#input\_aws\_efs\_csi\_driver\_helm\_config) | AWS EFS CSI driver Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_for_fluentbit_cw_log_group_kms_key_arn"></a> [aws\_for\_fluentbit\_cw\_log\_group\_kms\_key\_arn](#input\_aws\_for\_fluentbit\_cw\_log\_group\_kms\_key\_arn) | FluentBit CloudWatch Log group KMS Key | `string` | `null` | no |
| <a name="input_aws_for_fluentbit_cw_log_group_name"></a> [aws\_for\_fluentbit\_cw\_log\_group\_name](#input\_aws\_for\_fluentbit\_cw\_log\_group\_name) | FluentBit CloudWatch Log group name | `string` | `null` | no |
| <a name="input_aws_for_fluentbit_cw_log_group_retention"></a> [aws\_for\_fluentbit\_cw\_log\_group\_retention](#input\_aws\_for\_fluentbit\_cw\_log\_group\_retention) | FluentBit CloudWatch Log group retention period | `number` | `90` | no |
| <a name="input_aws_for_fluentbit_helm_config"></a> [aws\_for\_fluentbit\_helm\_config](#input\_aws\_for\_fluentbit\_helm\_config) | AWS for FluentBit Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_for_fluentbit_irsa_policies"></a> [aws\_for\_fluentbit\_irsa\_policies](#input\_aws\_for\_fluentbit\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_aws_load_balancer_controller_helm_config"></a> [aws\_load\_balancer\_controller\_helm\_config](#input\_aws\_load\_balancer\_controller\_helm\_config) | AWS Load Balancer Controller Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_load_balancer_controller_irsa_permissions_boundary"></a> [aws\_load\_balancer\_controller\_irsa\_permissions\_boundary](#input\_aws\_load\_balancer\_controller\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary | `string` | `""` | no |
| <a name="input_aws_node_termination_handler_helm_config"></a> [aws\_node\_termination\_handler\_helm\_config](#input\_aws\_node\_termination\_handler\_helm\_config) | AWS Node Termination Handler Helm Chart config | `any` | `{}` | no |
| <a name="input_cert_manager_helm_config"></a> [cert\_manager\_helm\_config](#input\_cert\_manager\_helm\_config) | Cert Manager Helm Chart config | `any` | `{}` | no |
| <a name="input_cluster_autoscaler_helm_config"></a> [cluster\_autoscaler\_helm\_config](#input\_cluster\_autoscaler\_helm\_config) | Cluster Autoscaler Helm Chart config | `any` | `{}` | no |
| <a name="input_cluster_autoscaler_irsa_permissions_boundary"></a> [cluster\_autoscaler\_irsa\_permissions\_boundary](#input\_cluster\_autoscaler\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary | `string` | `""` | no |
| <a name="input_crossplane_aws_provider"></a> [crossplane\_aws\_provider](#input\_crossplane\_aws\_provider) | AWS Provider config for Crossplane | <pre>object({<br>    enable                   = bool<br>    provider_aws_version     = string<br>    additional_irsa_policies = list(string)<br>  })</pre> | <pre>{<br>  "additional_irsa_policies": [],<br>  "enable": false,<br>  "provider_aws_version": "v0.24.1"<br>}</pre> | no |
| <a name="input_crossplane_helm_config"></a> [crossplane\_helm\_config](#input\_crossplane\_helm\_config) | Crossplane Helm Chart config | `any` | `null` | no |
| <a name="input_crossplane_jet_aws_provider"></a> [crossplane\_jet\_aws\_provider](#input\_crossplane\_jet\_aws\_provider) | AWS Provider Jet AWS config for Crossplane | <pre>object({<br>    enable                   = bool<br>    provider_aws_version     = string<br>    additional_irsa_policies = list(string)<br>  })</pre> | <pre>{<br>  "additional_irsa_policies": [],<br>  "enable": false,<br>  "provider_aws_version": "v0.24.1"<br>}</pre> | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster Id | `string` | n/a | yes |
| <a name="input_eks_worker_security_group_id"></a> [eks\_worker\_security\_group\_id](#input\_eks\_worker\_security\_group\_id) | EKS Worker Security group Id created by EKS module | `string` | `""` | no |
| <a name="input_enable_agones"></a> [enable\_agones](#input\_enable\_agones) | Enable Agones GamServer add-on | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_aws_ebs_csi_driver"></a> [enable\_amazon\_eks\_aws\_ebs\_csi\_driver](#input\_enable\_amazon\_eks\_aws\_ebs\_csi\_driver) | Enable EKS Managed AWS EBS CSI Driver add-on | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_coredns"></a> [enable\_amazon\_eks\_coredns](#input\_enable\_amazon\_eks\_coredns) | Enable CoreDNS add-on | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_kube_proxy"></a> [enable\_amazon\_eks\_kube\_proxy](#input\_enable\_amazon\_eks\_kube\_proxy) | Enable Kube Proxy add-on | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_vpc_cni"></a> [enable\_amazon\_eks\_vpc\_cni](#input\_enable\_amazon\_eks\_vpc\_cni) | Enable VPC CNI add-on | `bool` | `false` | no |
| <a name="input_enable_amazon_prometheus"></a> [enable\_amazon\_prometheus](#input\_enable\_amazon\_prometheus) | Enable AWS Managed Prometheus service | `bool` | `false` | no |
| <a name="input_enable_argo_rollouts"></a> [enable\_argo\_rollouts](#input\_enable\_argo\_rollouts) | Enable Argo Rollouts add-on | `bool` | `false` | no |
| <a name="input_enable_argocd"></a> [enable\_argocd](#input\_enable\_argocd) | Enable Argo CD Kubernetes add-on | `bool` | `false` | no |
| <a name="input_enable_aws_efs_csi_driver"></a> [enable\_aws\_efs\_csi\_driver](#input\_enable\_aws\_efs\_csi\_driver) | Enable AWS EFS CSI driver add-on | `bool` | `false` | no |
| <a name="input_enable_aws_for_fluentbit"></a> [enable\_aws\_for\_fluentbit](#input\_enable\_aws\_for\_fluentbit) | Enable AWS for FluentBit add-on | `bool` | `false` | no |
| <a name="input_enable_aws_load_balancer_controller"></a> [enable\_aws\_load\_balancer\_controller](#input\_enable\_aws\_load\_balancer\_controller) | Enable AWS Load Balancer Controller add-on | `bool` | `false` | no |
| <a name="input_enable_aws_node_termination_handler"></a> [enable\_aws\_node\_termination\_handler](#input\_enable\_aws\_node\_termination\_handler) | Enable AWS Node Termination Handler add-on | `bool` | `false` | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Enable Cert Manager add-on | `bool` | `false` | no |
| <a name="input_enable_cluster_autoscaler"></a> [enable\_cluster\_autoscaler](#input\_enable\_cluster\_autoscaler) | Enable Cluster autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_crossplane"></a> [enable\_crossplane](#input\_enable\_crossplane) | Enable Crossplane add-on | `bool` | `false` | no |
| <a name="input_enable_fargate_fluentbit"></a> [enable\_fargate\_fluentbit](#input\_enable\_fargate\_fluentbit) | Enable Fargate FluentBit add-on | `bool` | `false` | no |
| <a name="input_enable_ingress_nginx"></a> [enable\_ingress\_nginx](#input\_enable\_ingress\_nginx) | Enable Ingress Nginx add-on | `bool` | `false` | no |
| <a name="input_enable_karpenter"></a> [enable\_karpenter](#input\_enable\_karpenter) | Enable Karpenter autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_keda"></a> [enable\_keda](#input\_enable\_keda) | Enable KEDA Event-based autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_kubernetes_dashboard"></a> [enable\_kubernetes\_dashboard](#input\_enable\_kubernetes\_dashboard) | Enable Kubernetes Dashboard add-on | `bool` | `false` | no |
| <a name="input_enable_metrics_server"></a> [enable\_metrics\_server](#input\_enable\_metrics\_server) | Enable metrics server add-on | `bool` | `false` | no |
| <a name="input_enable_prometheus"></a> [enable\_prometheus](#input\_enable\_prometheus) | Enable Community Prometheus add-on | `bool` | `false` | no |
| <a name="input_enable_spark_k8s_operator"></a> [enable\_spark\_k8s\_operator](#input\_enable\_spark\_k8s\_operator) | Enable Spark on K8s Operator add-on | `bool` | `false` | no |
| <a name="input_enable_traefik"></a> [enable\_traefik](#input\_enable\_traefik) | Enable Traefik add-on | `bool` | `false` | no |
| <a name="input_enable_vpa"></a> [enable\_vpa](#input\_enable\_vpa) | Enable Vertical Pod Autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_yunikorn"></a> [enable\_yunikorn](#input\_enable\_yunikorn) | Enable Apache YuniKorn K8s scheduler add-on | `bool` | `false` | no |
| <a name="input_fargate_fluentbit_addon_config"></a> [fargate\_fluentbit\_addon\_config](#input\_fargate\_fluentbit\_addon\_config) | Fargate fluentbit add-on config | `any` | `{}` | no |
| <a name="input_ingress_nginx_helm_config"></a> [ingress\_nginx\_helm\_config](#input\_ingress\_nginx\_helm\_config) | Ingress Nginx Helm Chart config | `any` | `{}` | no |
| <a name="input_karpenter_helm_config"></a> [karpenter\_helm\_config](#input\_karpenter\_helm\_config) | Karpenter autoscaler add-on config | `any` | `{}` | no |
| <a name="input_karpenter_irsa_policies"></a> [karpenter\_irsa\_policies](#input\_karpenter\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_karpenter_node_iam_instance_profile"></a> [karpenter\_node\_iam\_instance\_profile](#input\_karpenter\_node\_iam\_instance\_profile) | Karpenter Node IAM Instance profile id | `string` | `""` | no |
| <a name="input_keda_create_irsa"></a> [keda\_create\_irsa](#input\_keda\_create\_irsa) | Indicates if the add-on should create a IAM role + service account | `bool` | `true` | no |
| <a name="input_keda_helm_config"></a> [keda\_helm\_config](#input\_keda\_helm\_config) | KEDA Event-based autoscaler add-on config | `any` | `{}` | no |
| <a name="input_keda_irsa_permissions_boundary"></a> [keda\_irsa\_permissions\_boundary](#input\_keda\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary | `string` | `""` | no |
| <a name="input_keda_irsa_policies"></a> [keda\_irsa\_policies](#input\_keda\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_kubernetes_dashboard_helm_config"></a> [kubernetes\_dashboard\_helm\_config](#input\_kubernetes\_dashboard\_helm\_config) | Kubernetes Dashboard Helm Chart config | `any` | `null` | no |
| <a name="input_kubernetes_dashboard_irsa_permissions_boundary"></a> [kubernetes\_dashboard\_irsa\_permissions\_boundary](#input\_kubernetes\_dashboard\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary | `string` | `""` | no |
| <a name="input_kubernetes_dashboard_irsa_policies"></a> [kubernetes\_dashboard\_irsa\_policies](#input\_kubernetes\_dashboard\_irsa\_policies) | IAM policy ARNs for Kubernetes Dashboard IRSA | `list(string)` | `[]` | no |
| <a name="input_metrics_server_helm_config"></a> [metrics\_server\_helm\_config](#input\_metrics\_server\_helm\_config) | Metrics Server Helm Chart config | `any` | `{}` | no |
| <a name="input_nginx_ingress_controller_irsa_permissions_boundary"></a> [nginx\_ingress\_controller\_irsa\_permissions\_boundary](#input\_nginx\_ingress\_controller\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary | `string` | `""` | no |
| <a name="input_nginx_irsa_policies"></a> [nginx\_irsa\_policies](#input\_nginx\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_node_groups_iam_role_arn"></a> [node\_groups\_iam\_role\_arn](#input\_node\_groups\_iam\_role\_arn) | Node Groups IAM role ARNs | `list(string)` | `[]` | no |
| <a name="input_node_termination_handler_irsa_permissions_boundary"></a> [node\_termination\_handler\_irsa\_permissions\_boundary](#input\_node\_termination\_handler\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary | `string` | `""` | no |
| <a name="input_node_termination_handler_irsa_policies"></a> [node\_termination\_handler\_irsa\_policies](#input\_node\_termination\_handler\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_prometheus_helm_config"></a> [prometheus\_helm\_config](#input\_prometheus\_helm\_config) | Community Prometheus Helm Chart config | `any` | `{}` | no |
| <a name="input_spark_irsa_permissions_boundary"></a> [spark\_irsa\_permissions\_boundary](#input\_spark\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary for Spark App | `string` | `""` | no |
| <a name="input_spark_irsa_policies"></a> [spark\_irsa\_policies](#input\_spark\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts for Spark App | `list(string)` | `[]` | no |
| <a name="input_spark_k8s_operator_helm_config"></a> [spark\_k8s\_operator\_helm\_config](#input\_spark\_k8s\_operator\_helm\_config) | Spark on K8s Operator Helm Chart config | `any` | `{}` | no |
| <a name="input_spark_operator_irsa_permissions_boundary"></a> [spark\_operator\_irsa\_permissions\_boundary](#input\_spark\_operator\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary for Spark Operator | `string` | `""` | no |
| <a name="input_spark_operator_irsa_policies"></a> [spark\_operator\_irsa\_policies](#input\_spark\_operator\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts for Spark Operator | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_traefik_helm_config"></a> [traefik\_helm\_config](#input\_traefik\_helm\_config) | Traefik Helm Chart config | `any` | `{}` | no |
| <a name="input_vpa_helm_config"></a> [vpa\_helm\_config](#input\_vpa\_helm\_config) | VPA Helm Chart config | `any` | `null` | no |
| <a name="input_yunikorn_helm_config"></a> [yunikorn\_helm\_config](#input\_yunikorn\_helm\_config) | Yunikorn Helm Chart config | `any` | `null` | no |
| <a name="input_yunikorn_irsa_permissions_boundary"></a> [yunikorn\_irsa\_permissions\_boundary](#input\_yunikorn\_irsa\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary | `string` | `""` | no |
| <a name="input_yunikorn_irsa_policies"></a> [yunikorn\_irsa\_policies](#input\_yunikorn\_irsa\_policies) | IAM policy ARNs for Yunikorn IRSA | `list(string)` | `[]` | no |

## Outputs

No outputs.

<!--- END_TF_DOCS --->
