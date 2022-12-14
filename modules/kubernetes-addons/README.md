# Kubernetes Addons

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.8 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_adot_collector_haproxy"></a> [adot\_collector\_haproxy](#module\_adot\_collector\_haproxy) | ./adot-collector-haproxy | n/a |
| <a name="module_adot_collector_java"></a> [adot\_collector\_java](#module\_adot\_collector\_java) | ./adot-collector-java | n/a |
| <a name="module_adot_collector_memcached"></a> [adot\_collector\_memcached](#module\_adot\_collector\_memcached) | ./adot-collector-memcached | n/a |
| <a name="module_adot_collector_nginx"></a> [adot\_collector\_nginx](#module\_adot\_collector\_nginx) | ./adot-collector-nginx | n/a |
| <a name="module_agones"></a> [agones](#module\_agones) | ./agones | n/a |
| <a name="module_airflow"></a> [airflow](#module\_airflow) | ./airflow | n/a |
| <a name="module_app_2048"></a> [app\_2048](#module\_app\_2048) | ./app-2048 | n/a |
| <a name="module_appmesh_controller"></a> [appmesh\_controller](#module\_appmesh\_controller) | ./appmesh-controller | n/a |
| <a name="module_argo_rollouts"></a> [argo\_rollouts](#module\_argo\_rollouts) | ./argo-rollouts | n/a |
| <a name="module_argo_workflows"></a> [argo\_workflows](#module\_argo\_workflows) | ./argo-workflows | n/a |
| <a name="module_argocd"></a> [argocd](#module\_argocd) | ./argocd | n/a |
| <a name="module_aws_cloudwatch_metrics"></a> [aws\_cloudwatch\_metrics](#module\_aws\_cloudwatch\_metrics) | ./aws-cloudwatch-metrics | n/a |
| <a name="module_aws_coredns"></a> [aws\_coredns](#module\_aws\_coredns) | ./aws-coredns | n/a |
| <a name="module_aws_ebs_csi_driver"></a> [aws\_ebs\_csi\_driver](#module\_aws\_ebs\_csi\_driver) | ./aws-ebs-csi-driver | n/a |
| <a name="module_aws_efs_csi_driver"></a> [aws\_efs\_csi\_driver](#module\_aws\_efs\_csi\_driver) | ./aws-efs-csi-driver | n/a |
| <a name="module_aws_for_fluent_bit"></a> [aws\_for\_fluent\_bit](#module\_aws\_for\_fluent\_bit) | ./aws-for-fluentbit | n/a |
| <a name="module_aws_fsx_csi_driver"></a> [aws\_fsx\_csi\_driver](#module\_aws\_fsx\_csi\_driver) | ./aws-fsx-csi-driver | n/a |
| <a name="module_aws_kube_proxy"></a> [aws\_kube\_proxy](#module\_aws\_kube\_proxy) | ./aws-kube-proxy | n/a |
| <a name="module_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#module\_aws\_load\_balancer\_controller) | ./aws-load-balancer-controller | n/a |
| <a name="module_aws_node_termination_handler"></a> [aws\_node\_termination\_handler](#module\_aws\_node\_termination\_handler) | ./aws-node-termination-handler | n/a |
| <a name="module_aws_privateca_issuer"></a> [aws\_privateca\_issuer](#module\_aws\_privateca\_issuer) | ./aws-privateca-issuer | n/a |
| <a name="module_aws_vpc_cni"></a> [aws\_vpc\_cni](#module\_aws\_vpc\_cni) | ./aws-vpc-cni | n/a |
| <a name="module_calico"></a> [calico](#module\_calico) | ./calico | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ./cert-manager | n/a |
| <a name="module_cert_manager_csi_driver"></a> [cert\_manager\_csi\_driver](#module\_cert\_manager\_csi\_driver) | ./cert-manager-csi-driver | n/a |
| <a name="module_cert_manager_istio_csr"></a> [cert\_manager\_istio\_csr](#module\_cert\_manager\_istio\_csr) | ./cert-manager-istio-csr | n/a |
| <a name="module_chaos_mesh"></a> [chaos\_mesh](#module\_chaos\_mesh) | ./chaos-mesh | n/a |
| <a name="module_cilium"></a> [cilium](#module\_cilium) | ./cilium | n/a |
| <a name="module_cluster_autoscaler"></a> [cluster\_autoscaler](#module\_cluster\_autoscaler) | ./cluster-autoscaler | n/a |
| <a name="module_consul"></a> [consul](#module\_consul) | ./consul | n/a |
| <a name="module_coredns_autoscaler"></a> [coredns\_autoscaler](#module\_coredns\_autoscaler) | ./cluster-proportional-autoscaler | n/a |
| <a name="module_crossplane"></a> [crossplane](#module\_crossplane) | ./crossplane | n/a |
| <a name="module_csi_secrets_store_provider_aws"></a> [csi\_secrets\_store\_provider\_aws](#module\_csi\_secrets\_store\_provider\_aws) | ./csi-secrets-store-provider-aws | n/a |
| <a name="module_datadog_operator"></a> [datadog\_operator](#module\_datadog\_operator) | ./datadog-operator | n/a |
| <a name="module_emr_on_eks"></a> [emr\_on\_eks](#module\_emr\_on\_eks) | ./emr-on-eks | n/a |
| <a name="module_external_dns"></a> [external\_dns](#module\_external\_dns) | ./external-dns | n/a |
| <a name="module_external_secrets"></a> [external\_secrets](#module\_external\_secrets) | ./external-secrets | n/a |
| <a name="module_fargate_fluentbit"></a> [fargate\_fluentbit](#module\_fargate\_fluentbit) | ./fargate-fluentbit | n/a |
| <a name="module_gatekeeper"></a> [gatekeeper](#module\_gatekeeper) | ./gatekeeper | n/a |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | ./grafana | n/a |
| <a name="module_ingress_nginx"></a> [ingress\_nginx](#module\_ingress\_nginx) | ./ingress-nginx | n/a |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | ./karpenter | n/a |
| <a name="module_keda"></a> [keda](#module\_keda) | ./keda | n/a |
| <a name="module_kube_prometheus_stack"></a> [kube\_prometheus\_stack](#module\_kube\_prometheus\_stack) | ./kube-prometheus-stack | n/a |
| <a name="module_kubecost"></a> [kubecost](#module\_kubecost) | ./kubecost | n/a |
| <a name="module_kuberay_operator"></a> [kuberay\_operator](#module\_kuberay\_operator) | ./kuberay-operator | n/a |
| <a name="module_kubernetes_dashboard"></a> [kubernetes\_dashboard](#module\_kubernetes\_dashboard) | ./kubernetes-dashboard | n/a |
| <a name="module_kyverno"></a> [kyverno](#module\_kyverno) | ./kyverno | n/a |
| <a name="module_local_volume_provisioner"></a> [local\_volume\_provisioner](#module\_local\_volume\_provisioner) | ./local-volume-provisioner | n/a |
| <a name="module_metrics_server"></a> [metrics\_server](#module\_metrics\_server) | ./metrics-server | n/a |
| <a name="module_nvidia_device_plugin"></a> [nvidia\_device\_plugin](#module\_nvidia\_device\_plugin) | ./nvidia-device-plugin | n/a |
| <a name="module_ondat"></a> [ondat](#module\_ondat) | ondat/ondat-addon/eksblueprints | 0.1.2 |
| <a name="module_opentelemetry_operator"></a> [opentelemetry\_operator](#module\_opentelemetry\_operator) | ./opentelemetry-operator | n/a |
| <a name="module_portworx"></a> [portworx](#module\_portworx) | portworx/portworx-addon/eksblueprints | 0.0.6 |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | ./prometheus | n/a |
| <a name="module_promtail"></a> [promtail](#module\_promtail) | ./promtail | n/a |
| <a name="module_reloader"></a> [reloader](#module\_reloader) | ./reloader | n/a |
| <a name="module_secrets_store_csi_driver"></a> [secrets\_store\_csi\_driver](#module\_secrets\_store\_csi\_driver) | ./secrets-store-csi-driver | n/a |
| <a name="module_smb_csi_driver"></a> [smb\_csi\_driver](#module\_smb\_csi\_driver) | ./smb-csi-driver | n/a |
| <a name="module_spark_history_server"></a> [spark\_history\_server](#module\_spark\_history\_server) | ./spark-history-server | n/a |
| <a name="module_spark_k8s_operator"></a> [spark\_k8s\_operator](#module\_spark\_k8s\_operator) | ./spark-k8s-operator | n/a |
| <a name="module_strimzi_kafka_operator"></a> [strimzi\_kafka\_operator](#module\_strimzi\_kafka\_operator) | ./strimzi-kafka-operator | n/a |
| <a name="module_sysdig_agent"></a> [sysdig\_agent](#module\_sysdig\_agent) | sysdiglabs/sysdig-addon/eksblueprints | 0.0.1 |
| <a name="module_tetrate_istio"></a> [tetrate\_istio](#module\_tetrate\_istio) | ./tetrate-istio | n/a |
| <a name="module_thanos"></a> [thanos](#module\_thanos) | ./thanos | n/a |
| <a name="module_traefik"></a> [traefik](#module\_traefik) | ./traefik | n/a |
| <a name="module_vault"></a> [vault](#module\_vault) | hashicorp/hashicorp-vault-eks-addon/aws | 1.0.0-rc2 |
| <a name="module_velero"></a> [velero](#module\_velero) | ./velero | n/a |
| <a name="module_vpa"></a> [vpa](#module\_vpa) | ./vpa | n/a |
| <a name="module_yunikorn"></a> [yunikorn](#module\_yunikorn) | ./yunikorn | n/a |

## Resources

| Name | Type |
|------|------|
| [time_sleep.dataplane](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adot_collector_haproxy_helm_config"></a> [adot\_collector\_haproxy\_helm\_config](#input\_adot\_collector\_haproxy\_helm\_config) | ADOT Collector HAProxy Helm Chart config | `any` | `{}` | no |
| <a name="input_adot_collector_java_helm_config"></a> [adot\_collector\_java\_helm\_config](#input\_adot\_collector\_java\_helm\_config) | ADOT Collector Java Helm Chart config | `any` | `{}` | no |
| <a name="input_adot_collector_memcached_helm_config"></a> [adot\_collector\_memcached\_helm\_config](#input\_adot\_collector\_memcached\_helm\_config) | ADOT Collector Memcached Helm Chart config | `any` | `{}` | no |
| <a name="input_adot_collector_nginx_helm_config"></a> [adot\_collector\_nginx\_helm\_config](#input\_adot\_collector\_nginx\_helm\_config) | ADOT Collector Nginx Helm Chart config | `any` | `{}` | no |
| <a name="input_agones_helm_config"></a> [agones\_helm\_config](#input\_agones\_helm\_config) | Agones GameServer Helm Chart config | `any` | `{}` | no |
| <a name="input_airflow_helm_config"></a> [airflow\_helm\_config](#input\_airflow\_helm\_config) | Apache Airflow v2 Helm Chart config | `any` | `{}` | no |
| <a name="input_amazon_eks_adot_config"></a> [amazon\_eks\_adot\_config](#input\_amazon\_eks\_adot\_config) | Configuration for Amazon EKS ADOT add-on | `any` | `{}` | no |
| <a name="input_amazon_eks_aws_ebs_csi_driver_config"></a> [amazon\_eks\_aws\_ebs\_csi\_driver\_config](#input\_amazon\_eks\_aws\_ebs\_csi\_driver\_config) | configMap for AWS EBS CSI Driver add-on | `any` | `{}` | no |
| <a name="input_amazon_eks_coredns_config"></a> [amazon\_eks\_coredns\_config](#input\_amazon\_eks\_coredns\_config) | Configuration for Amazon CoreDNS EKS add-on | `any` | `{}` | no |
| <a name="input_amazon_eks_kube_proxy_config"></a> [amazon\_eks\_kube\_proxy\_config](#input\_amazon\_eks\_kube\_proxy\_config) | ConfigMap for Amazon EKS Kube-Proxy add-on | `any` | `{}` | no |
| <a name="input_amazon_eks_vpc_cni_config"></a> [amazon\_eks\_vpc\_cni\_config](#input\_amazon\_eks\_vpc\_cni\_config) | ConfigMap of Amazon EKS VPC CNI add-on | `any` | `{}` | no |
| <a name="input_amazon_prometheus_workspace_endpoint"></a> [amazon\_prometheus\_workspace\_endpoint](#input\_amazon\_prometheus\_workspace\_endpoint) | AWS Managed Prometheus WorkSpace Endpoint | `string` | `null` | no |
| <a name="input_amazon_prometheus_workspace_region"></a> [amazon\_prometheus\_workspace\_region](#input\_amazon\_prometheus\_workspace\_region) | AWS Managed Prometheus WorkSpace Region | `string` | `null` | no |
| <a name="input_appmesh_helm_config"></a> [appmesh\_helm\_config](#input\_appmesh\_helm\_config) | AppMesh Helm Chart config | `any` | `{}` | no |
| <a name="input_appmesh_irsa_policies"></a> [appmesh\_irsa\_policies](#input\_appmesh\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_argo_rollouts_helm_config"></a> [argo\_rollouts\_helm\_config](#input\_argo\_rollouts\_helm\_config) | Argo Rollouts Helm Chart config | `any` | `null` | no |
| <a name="input_argo_workflows_helm_config"></a> [argo\_workflows\_helm\_config](#input\_argo\_workflows\_helm\_config) | Argo workflows Helm Chart config | `any` | `null` | no |
| <a name="input_argocd_applications"></a> [argocd\_applications](#input\_argocd\_applications) | Argo CD Applications config to bootstrap the cluster | `any` | `{}` | no |
| <a name="input_argocd_helm_config"></a> [argocd\_helm\_config](#input\_argocd\_helm\_config) | Argo CD Kubernetes add-on config | `any` | `{}` | no |
| <a name="input_argocd_manage_add_ons"></a> [argocd\_manage\_add\_ons](#input\_argocd\_manage\_add\_ons) | Enable managing add-on configuration via ArgoCD App of Apps | `bool` | `false` | no |
| <a name="input_auto_scaling_group_names"></a> [auto\_scaling\_group\_names](#input\_auto\_scaling\_group\_names) | List of self-managed node groups autoscaling group names | `list(string)` | `[]` | no |
| <a name="input_aws_cloudwatch_metrics_helm_config"></a> [aws\_cloudwatch\_metrics\_helm\_config](#input\_aws\_cloudwatch\_metrics\_helm\_config) | AWS CloudWatch Metrics Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_cloudwatch_metrics_irsa_policies"></a> [aws\_cloudwatch\_metrics\_irsa\_policies](#input\_aws\_cloudwatch\_metrics\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_aws_efs_csi_driver_helm_config"></a> [aws\_efs\_csi\_driver\_helm\_config](#input\_aws\_efs\_csi\_driver\_helm\_config) | AWS EFS CSI driver Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_efs_csi_driver_irsa_policies"></a> [aws\_efs\_csi\_driver\_irsa\_policies](#input\_aws\_efs\_csi\_driver\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_aws_for_fluentbit_create_cw_log_group"></a> [aws\_for\_fluentbit\_create\_cw\_log\_group](#input\_aws\_for\_fluentbit\_create\_cw\_log\_group) | Set to false to use existing CloudWatch log group supplied via the cw\_log\_group\_name variable. | `bool` | `true` | no |
| <a name="input_aws_for_fluentbit_cw_log_group_kms_key_arn"></a> [aws\_for\_fluentbit\_cw\_log\_group\_kms\_key\_arn](#input\_aws\_for\_fluentbit\_cw\_log\_group\_kms\_key\_arn) | FluentBit CloudWatch Log group KMS Key | `string` | `null` | no |
| <a name="input_aws_for_fluentbit_cw_log_group_name"></a> [aws\_for\_fluentbit\_cw\_log\_group\_name](#input\_aws\_for\_fluentbit\_cw\_log\_group\_name) | FluentBit CloudWatch Log group name | `string` | `null` | no |
| <a name="input_aws_for_fluentbit_cw_log_group_retention"></a> [aws\_for\_fluentbit\_cw\_log\_group\_retention](#input\_aws\_for\_fluentbit\_cw\_log\_group\_retention) | FluentBit CloudWatch Log group retention period | `number` | `90` | no |
| <a name="input_aws_for_fluentbit_helm_config"></a> [aws\_for\_fluentbit\_helm\_config](#input\_aws\_for\_fluentbit\_helm\_config) | AWS for FluentBit Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_for_fluentbit_irsa_policies"></a> [aws\_for\_fluentbit\_irsa\_policies](#input\_aws\_for\_fluentbit\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_aws_fsx_csi_driver_helm_config"></a> [aws\_fsx\_csi\_driver\_helm\_config](#input\_aws\_fsx\_csi\_driver\_helm\_config) | AWS FSx CSI driver Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_fsx_csi_driver_irsa_policies"></a> [aws\_fsx\_csi\_driver\_irsa\_policies](#input\_aws\_fsx\_csi\_driver\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_aws_load_balancer_controller_helm_config"></a> [aws\_load\_balancer\_controller\_helm\_config](#input\_aws\_load\_balancer\_controller\_helm\_config) | AWS Load Balancer Controller Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_node_termination_handler_helm_config"></a> [aws\_node\_termination\_handler\_helm\_config](#input\_aws\_node\_termination\_handler\_helm\_config) | AWS Node Termination Handler Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_node_termination_handler_irsa_policies"></a> [aws\_node\_termination\_handler\_irsa\_policies](#input\_aws\_node\_termination\_handler\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_aws_privateca_acmca_arn"></a> [aws\_privateca\_acmca\_arn](#input\_aws\_privateca\_acmca\_arn) | ARN of AWS ACM PCA | `string` | `""` | no |
| <a name="input_aws_privateca_issuer_helm_config"></a> [aws\_privateca\_issuer\_helm\_config](#input\_aws\_privateca\_issuer\_helm\_config) | PCA Issuer Helm Chart config | `any` | `{}` | no |
| <a name="input_aws_privateca_issuer_irsa_policies"></a> [aws\_privateca\_issuer\_irsa\_policies](#input\_aws\_privateca\_issuer\_irsa\_policies) | IAM policy ARNs for AWS ACM PCA IRSA | `list(string)` | `[]` | no |
| <a name="input_calico_helm_config"></a> [calico\_helm\_config](#input\_calico\_helm\_config) | Calico add-on config | `any` | `{}` | no |
| <a name="input_cert_manager_csi_driver_helm_config"></a> [cert\_manager\_csi\_driver\_helm\_config](#input\_cert\_manager\_csi\_driver\_helm\_config) | Cert Manager CSI Driver Helm Chart config | `any` | `{}` | no |
| <a name="input_cert_manager_domain_names"></a> [cert\_manager\_domain\_names](#input\_cert\_manager\_domain\_names) | Domain names of the Route53 hosted zone to use with cert-manager | `list(string)` | `[]` | no |
| <a name="input_cert_manager_helm_config"></a> [cert\_manager\_helm\_config](#input\_cert\_manager\_helm\_config) | Cert Manager Helm Chart config | `any` | `{}` | no |
| <a name="input_cert_manager_install_letsencrypt_issuers"></a> [cert\_manager\_install\_letsencrypt\_issuers](#input\_cert\_manager\_install\_letsencrypt\_issuers) | Install Let's Encrypt Cluster Issuers | `bool` | `true` | no |
| <a name="input_cert_manager_irsa_policies"></a> [cert\_manager\_irsa\_policies](#input\_cert\_manager\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_cert_manager_istio_csr_helm_config"></a> [cert\_manager\_istio\_csr\_helm\_config](#input\_cert\_manager\_istio\_csr\_helm\_config) | Cert Manager Istio CSR Helm Chart config | `any` | `{}` | no |
| <a name="input_cert_manager_kubernetes_svc_image_pull_secrets"></a> [cert\_manager\_kubernetes\_svc\_image\_pull\_secrets](#input\_cert\_manager\_kubernetes\_svc\_image\_pull\_secrets) | list(string) of kubernetes imagePullSecrets | `list(string)` | `[]` | no |
| <a name="input_cert_manager_letsencrypt_email"></a> [cert\_manager\_letsencrypt\_email](#input\_cert\_manager\_letsencrypt\_email) | Email address for expiration emails from Let's Encrypt | `string` | `""` | no |
| <a name="input_chaos_mesh_helm_config"></a> [chaos\_mesh\_helm\_config](#input\_chaos\_mesh\_helm\_config) | Chaos Mesh Helm Chart config | `any` | `{}` | no |
| <a name="input_cilium_enable_wireguard"></a> [cilium\_enable\_wireguard](#input\_cilium\_enable\_wireguard) | Enable wiregaurd encryption | `bool` | `false` | no |
| <a name="input_cilium_helm_config"></a> [cilium\_helm\_config](#input\_cilium\_helm\_config) | Cilium Helm Chart config | `any` | `{}` | no |
| <a name="input_cluster_autoscaler_helm_config"></a> [cluster\_autoscaler\_helm\_config](#input\_cluster\_autoscaler\_helm\_config) | Cluster Autoscaler Helm Chart config | `any` | `{}` | no |
| <a name="input_consul_helm_config"></a> [consul\_helm\_config](#input\_consul\_helm\_config) | Consul Helm Chart config | `any` | `{}` | no |
| <a name="input_coredns_autoscaler_helm_config"></a> [coredns\_autoscaler\_helm\_config](#input\_coredns\_autoscaler\_helm\_config) | CoreDNS Autoscaler Helm Chart config | `any` | `{}` | no |
| <a name="input_coredns_cluster_proportional_autoscaler_helm_config"></a> [coredns\_cluster\_proportional\_autoscaler\_helm\_config](#input\_coredns\_cluster\_proportional\_autoscaler\_helm\_config) | Helm provider config for the CoreDNS cluster-proportional-autoscaler | `any` | `{}` | no |
| <a name="input_crossplane_aws_provider"></a> [crossplane\_aws\_provider](#input\_crossplane\_aws\_provider) | AWS Provider config for Crossplane | `any` | <pre>{<br>  "enable": false<br>}</pre> | no |
| <a name="input_crossplane_helm_config"></a> [crossplane\_helm\_config](#input\_crossplane\_helm\_config) | Crossplane Helm Chart config | `any` | `null` | no |
| <a name="input_crossplane_jet_aws_provider"></a> [crossplane\_jet\_aws\_provider](#input\_crossplane\_jet\_aws\_provider) | AWS Provider Jet AWS config for Crossplane | <pre>object({<br>    enable                   = bool<br>    provider_aws_version     = string<br>    additional_irsa_policies = list(string)<br>  })</pre> | <pre>{<br>  "additional_irsa_policies": [],<br>  "enable": false,<br>  "provider_aws_version": "v0.24.1"<br>}</pre> | no |
| <a name="input_crossplane_kubernetes_provider"></a> [crossplane\_kubernetes\_provider](#input\_crossplane\_kubernetes\_provider) | Kubernetes Provider config for Crossplane | `any` | <pre>{<br>  "enable": false<br>}</pre> | no |
| <a name="input_csi_secrets_store_provider_aws_helm_config"></a> [csi\_secrets\_store\_provider\_aws\_helm\_config](#input\_csi\_secrets\_store\_provider\_aws\_helm\_config) | CSI Secrets Store Provider AWS Helm Configurations | `any` | `null` | no |
| <a name="input_custom_image_registry_uri"></a> [custom\_image\_registry\_uri](#input\_custom\_image\_registry\_uri) | Custom image registry URI map of `{region = dkr.endpoint }` | `map(string)` | `{}` | no |
| <a name="input_data_plane_wait_arn"></a> [data\_plane\_wait\_arn](#input\_data\_plane\_wait\_arn) | Addon deployment will not proceed until this value is known. Set to node group/Fargate profile ARN to wait for data plane to be ready before provisioning addons | `string` | `""` | no |
| <a name="input_datadog_operator_helm_config"></a> [datadog\_operator\_helm\_config](#input\_datadog\_operator\_helm\_config) | Datadog Operator Helm Chart config | `any` | `{}` | no |
| <a name="input_eks_cluster_domain"></a> [eks\_cluster\_domain](#input\_eks\_cluster\_domain) | The domain for the EKS cluster | `string` | `""` | no |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | Endpoint for your Kubernetes API server | `string` | `null` | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS Cluster Id | `string` | n/a | yes |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | The Kubernetes version for the cluster | `string` | `null` | no |
| <a name="input_eks_oidc_provider"></a> [eks\_oidc\_provider](#input\_eks\_oidc\_provider) | The OpenID Connect identity provider (issuer URL without leading `https://`) | `string` | `null` | no |
| <a name="input_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#input\_eks\_oidc\_provider\_arn) | The OpenID Connect identity provider ARN | `string` | `null` | no |
| <a name="input_eks_worker_security_group_id"></a> [eks\_worker\_security\_group\_id](#input\_eks\_worker\_security\_group\_id) | EKS Worker Security group Id created by EKS module | `string` | `""` | no |
| <a name="input_emr_on_eks_config"></a> [emr\_on\_eks\_config](#input\_emr\_on\_eks\_config) | EMR on EKS Helm configuration values | `any` | `{}` | no |
| <a name="input_enable_adot_collector_haproxy"></a> [enable\_adot\_collector\_haproxy](#input\_enable\_adot\_collector\_haproxy) | Enable metrics for HAProxy workloads | `bool` | `false` | no |
| <a name="input_enable_adot_collector_java"></a> [enable\_adot\_collector\_java](#input\_enable\_adot\_collector\_java) | Enable metrics for JMX workloads | `bool` | `false` | no |
| <a name="input_enable_adot_collector_memcached"></a> [enable\_adot\_collector\_memcached](#input\_enable\_adot\_collector\_memcached) | Enable metrics for Memcached workloads | `bool` | `false` | no |
| <a name="input_enable_adot_collector_nginx"></a> [enable\_adot\_collector\_nginx](#input\_enable\_adot\_collector\_nginx) | Enable metrics for Nginx workloads | `bool` | `false` | no |
| <a name="input_enable_agones"></a> [enable\_agones](#input\_enable\_agones) | Enable Agones GamServer add-on | `bool` | `false` | no |
| <a name="input_enable_airflow"></a> [enable\_airflow](#input\_enable\_airflow) | Enable Airflow add-on | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_adot"></a> [enable\_amazon\_eks\_adot](#input\_enable\_amazon\_eks\_adot) | Enable Amazon EKS ADOT addon | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_aws_ebs_csi_driver"></a> [enable\_amazon\_eks\_aws\_ebs\_csi\_driver](#input\_enable\_amazon\_eks\_aws\_ebs\_csi\_driver) | Enable EKS Managed AWS EBS CSI Driver add-on; enable\_amazon\_eks\_aws\_ebs\_csi\_driver and enable\_self\_managed\_aws\_ebs\_csi\_driver are mutually exclusive | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_coredns"></a> [enable\_amazon\_eks\_coredns](#input\_enable\_amazon\_eks\_coredns) | Enable Amazon EKS CoreDNS add-on | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_kube_proxy"></a> [enable\_amazon\_eks\_kube\_proxy](#input\_enable\_amazon\_eks\_kube\_proxy) | Enable Kube Proxy add-on | `bool` | `false` | no |
| <a name="input_enable_amazon_eks_vpc_cni"></a> [enable\_amazon\_eks\_vpc\_cni](#input\_enable\_amazon\_eks\_vpc\_cni) | Enable VPC CNI add-on | `bool` | `false` | no |
| <a name="input_enable_amazon_prometheus"></a> [enable\_amazon\_prometheus](#input\_enable\_amazon\_prometheus) | Enable AWS Managed Prometheus service | `bool` | `false` | no |
| <a name="input_enable_app_2048"></a> [enable\_app\_2048](#input\_enable\_app\_2048) | Enable sample app 2048 | `bool` | `false` | no |
| <a name="input_enable_appmesh_controller"></a> [enable\_appmesh\_controller](#input\_enable\_appmesh\_controller) | Enable AppMesh add-on | `bool` | `false` | no |
| <a name="input_enable_argo_rollouts"></a> [enable\_argo\_rollouts](#input\_enable\_argo\_rollouts) | Enable Argo Rollouts add-on | `bool` | `false` | no |
| <a name="input_enable_argo_workflows"></a> [enable\_argo\_workflows](#input\_enable\_argo\_workflows) | Enable Argo workflows add-on | `bool` | `false` | no |
| <a name="input_enable_argocd"></a> [enable\_argocd](#input\_enable\_argocd) | Enable Argo CD Kubernetes add-on | `bool` | `false` | no |
| <a name="input_enable_aws_cloudwatch_metrics"></a> [enable\_aws\_cloudwatch\_metrics](#input\_enable\_aws\_cloudwatch\_metrics) | Enable AWS CloudWatch Metrics add-on for Container Insights | `bool` | `false` | no |
| <a name="input_enable_aws_efs_csi_driver"></a> [enable\_aws\_efs\_csi\_driver](#input\_enable\_aws\_efs\_csi\_driver) | Enable AWS EFS CSI driver add-on | `bool` | `false` | no |
| <a name="input_enable_aws_for_fluentbit"></a> [enable\_aws\_for\_fluentbit](#input\_enable\_aws\_for\_fluentbit) | Enable AWS for FluentBit add-on | `bool` | `false` | no |
| <a name="input_enable_aws_fsx_csi_driver"></a> [enable\_aws\_fsx\_csi\_driver](#input\_enable\_aws\_fsx\_csi\_driver) | Enable AWS FSx CSI driver add-on | `bool` | `false` | no |
| <a name="input_enable_aws_load_balancer_controller"></a> [enable\_aws\_load\_balancer\_controller](#input\_enable\_aws\_load\_balancer\_controller) | Enable AWS Load Balancer Controller add-on | `bool` | `false` | no |
| <a name="input_enable_aws_node_termination_handler"></a> [enable\_aws\_node\_termination\_handler](#input\_enable\_aws\_node\_termination\_handler) | Enable AWS Node Termination Handler add-on | `bool` | `false` | no |
| <a name="input_enable_aws_privateca_issuer"></a> [enable\_aws\_privateca\_issuer](#input\_enable\_aws\_privateca\_issuer) | Enable PCA Issuer | `bool` | `false` | no |
| <a name="input_enable_calico"></a> [enable\_calico](#input\_enable\_calico) | Enable Calico add-on | `bool` | `false` | no |
| <a name="input_enable_cert_manager"></a> [enable\_cert\_manager](#input\_enable\_cert\_manager) | Enable Cert Manager add-on | `bool` | `false` | no |
| <a name="input_enable_cert_manager_csi_driver"></a> [enable\_cert\_manager\_csi\_driver](#input\_enable\_cert\_manager\_csi\_driver) | Enable Cert Manager CSI Driver add-on | `bool` | `false` | no |
| <a name="input_enable_cert_manager_istio_csr"></a> [enable\_cert\_manager\_istio\_csr](#input\_enable\_cert\_manager\_istio\_csr) | Enable Cert Manager istio-csr add-on | `bool` | `false` | no |
| <a name="input_enable_chaos_mesh"></a> [enable\_chaos\_mesh](#input\_enable\_chaos\_mesh) | Enable Chaos Mesh add-on | `bool` | `false` | no |
| <a name="input_enable_cilium"></a> [enable\_cilium](#input\_enable\_cilium) | Enable Cilium add-on | `bool` | `false` | no |
| <a name="input_enable_cluster_autoscaler"></a> [enable\_cluster\_autoscaler](#input\_enable\_cluster\_autoscaler) | Enable Cluster autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_consul"></a> [enable\_consul](#input\_enable\_consul) | Enable consul add-on | `bool` | `false` | no |
| <a name="input_enable_coredns_autoscaler"></a> [enable\_coredns\_autoscaler](#input\_enable\_coredns\_autoscaler) | Enable CoreDNS autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_coredns_cluster_proportional_autoscaler"></a> [enable\_coredns\_cluster\_proportional\_autoscaler](#input\_enable\_coredns\_cluster\_proportional\_autoscaler) | Enable cluster-proportional-autoscaler for CoreDNS | `bool` | `true` | no |
| <a name="input_enable_crossplane"></a> [enable\_crossplane](#input\_enable\_crossplane) | Enable Crossplane add-on | `bool` | `false` | no |
| <a name="input_enable_datadog_operator"></a> [enable\_datadog\_operator](#input\_enable\_datadog\_operator) | Enable Datadog Operator add-on | `bool` | `false` | no |
| <a name="input_enable_emr_on_eks"></a> [enable\_emr\_on\_eks](#input\_enable\_emr\_on\_eks) | Enable EMR on EKS add-on | `bool` | `false` | no |
| <a name="input_enable_external_dns"></a> [enable\_external\_dns](#input\_enable\_external\_dns) | External DNS add-on | `bool` | `false` | no |
| <a name="input_enable_external_secrets"></a> [enable\_external\_secrets](#input\_enable\_external\_secrets) | Enable External Secrets operator add-on | `bool` | `false` | no |
| <a name="input_enable_fargate_fluentbit"></a> [enable\_fargate\_fluentbit](#input\_enable\_fargate\_fluentbit) | Enable Fargate FluentBit add-on | `bool` | `false` | no |
| <a name="input_enable_gatekeeper"></a> [enable\_gatekeeper](#input\_enable\_gatekeeper) | Enable Gatekeeper add-on | `bool` | `false` | no |
| <a name="input_enable_grafana"></a> [enable\_grafana](#input\_enable\_grafana) | Enable Grafana add-on | `bool` | `false` | no |
| <a name="input_enable_ingress_nginx"></a> [enable\_ingress\_nginx](#input\_enable\_ingress\_nginx) | Enable Ingress Nginx add-on | `bool` | `false` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Enable Ipv6 network. Attaches new VPC CNI policy to the IRSA role | `bool` | `false` | no |
| <a name="input_enable_karpenter"></a> [enable\_karpenter](#input\_enable\_karpenter) | Enable Karpenter autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_keda"></a> [enable\_keda](#input\_enable\_keda) | Enable KEDA Event-based autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_kube_prometheus_stack"></a> [enable\_kube\_prometheus\_stack](#input\_enable\_kube\_prometheus\_stack) | Enable Community kube-prometheus-stack add-on | `bool` | `false` | no |
| <a name="input_enable_kubecost"></a> [enable\_kubecost](#input\_enable\_kubecost) | Enable Kubecost add-on | `bool` | `false` | no |
| <a name="input_enable_kuberay_operator"></a> [enable\_kuberay\_operator](#input\_enable\_kuberay\_operator) | Enable KubeRay Operator add-on | `bool` | `false` | no |
| <a name="input_enable_kubernetes_dashboard"></a> [enable\_kubernetes\_dashboard](#input\_enable\_kubernetes\_dashboard) | Enable Kubernetes Dashboard add-on | `bool` | `false` | no |
| <a name="input_enable_kyverno"></a> [enable\_kyverno](#input\_enable\_kyverno) | Enable Kyverno add-on | `bool` | `false` | no |
| <a name="input_enable_kyverno_policies"></a> [enable\_kyverno\_policies](#input\_enable\_kyverno\_policies) | Enable Kyverno policies. Requires `enable_kyverno` to be `true` | `bool` | `false` | no |
| <a name="input_enable_kyverno_policy_reporter"></a> [enable\_kyverno\_policy\_reporter](#input\_enable\_kyverno\_policy\_reporter) | Enable Kyverno UI. Requires `enable_kyverno` to be `true` | `bool` | `false` | no |
| <a name="input_enable_local_volume_provisioner"></a> [enable\_local\_volume\_provisioner](#input\_enable\_local\_volume\_provisioner) | Enable Local volume provisioner add-on | `bool` | `false` | no |
| <a name="input_enable_metrics_server"></a> [enable\_metrics\_server](#input\_enable\_metrics\_server) | Enable metrics server add-on | `bool` | `false` | no |
| <a name="input_enable_nvidia_device_plugin"></a> [enable\_nvidia\_device\_plugin](#input\_enable\_nvidia\_device\_plugin) | Enable NVIDIA device plugin add-on | `bool` | `false` | no |
| <a name="input_enable_ondat"></a> [enable\_ondat](#input\_enable\_ondat) | Enable Ondat add-on | `bool` | `false` | no |
| <a name="input_enable_opentelemetry_operator"></a> [enable\_opentelemetry\_operator](#input\_enable\_opentelemetry\_operator) | Enable opentelemetry operator add-on | `bool` | `false` | no |
| <a name="input_enable_portworx"></a> [enable\_portworx](#input\_enable\_portworx) | Enable Kubernetes Dashboard add-on | `bool` | `false` | no |
| <a name="input_enable_prometheus"></a> [enable\_prometheus](#input\_enable\_prometheus) | Enable Community Prometheus add-on | `bool` | `false` | no |
| <a name="input_enable_promtail"></a> [enable\_promtail](#input\_enable\_promtail) | Enable Promtail add-on | `bool` | `false` | no |
| <a name="input_enable_reloader"></a> [enable\_reloader](#input\_enable\_reloader) | Enable Reloader add-on | `bool` | `false` | no |
| <a name="input_enable_secrets_store_csi_driver"></a> [enable\_secrets\_store\_csi\_driver](#input\_enable\_secrets\_store\_csi\_driver) | Enable CSI Secrets Store Provider | `bool` | `false` | no |
| <a name="input_enable_secrets_store_csi_driver_provider_aws"></a> [enable\_secrets\_store\_csi\_driver\_provider\_aws](#input\_enable\_secrets\_store\_csi\_driver\_provider\_aws) | Enable AWS CSI Secrets Store Provider | `bool` | `false` | no |
| <a name="input_enable_self_managed_aws_ebs_csi_driver"></a> [enable\_self\_managed\_aws\_ebs\_csi\_driver](#input\_enable\_self\_managed\_aws\_ebs\_csi\_driver) | Enable self-managed aws-ebs-csi-driver add-on; enable\_self\_managed\_aws\_ebs\_csi\_driver and enable\_amazon\_eks\_aws\_ebs\_csi\_driver are mutually exclusive | `bool` | `false` | no |
| <a name="input_enable_self_managed_coredns"></a> [enable\_self\_managed\_coredns](#input\_enable\_self\_managed\_coredns) | Enable self-managed CoreDNS add-on | `bool` | `false` | no |
| <a name="input_enable_smb_csi_driver"></a> [enable\_smb\_csi\_driver](#input\_enable\_smb\_csi\_driver) | Enable SMB CSI driver add-on | `bool` | `false` | no |
| <a name="input_enable_spark_history_server"></a> [enable\_spark\_history\_server](#input\_enable\_spark\_history\_server) | Enable Spark History Server add-on | `bool` | `false` | no |
| <a name="input_enable_spark_k8s_operator"></a> [enable\_spark\_k8s\_operator](#input\_enable\_spark\_k8s\_operator) | Enable Spark on K8s Operator add-on | `bool` | `false` | no |
| <a name="input_enable_strimzi_kafka_operator"></a> [enable\_strimzi\_kafka\_operator](#input\_enable\_strimzi\_kafka\_operator) | Enable Kafka add-on | `bool` | `false` | no |
| <a name="input_enable_sysdig_agent"></a> [enable\_sysdig\_agent](#input\_enable\_sysdig\_agent) | Enable Sysdig Agent add-on | `bool` | `false` | no |
| <a name="input_enable_tetrate_istio"></a> [enable\_tetrate\_istio](#input\_enable\_tetrate\_istio) | Enable Tetrate Istio add-on | `bool` | `false` | no |
| <a name="input_enable_thanos"></a> [enable\_thanos](#input\_enable\_thanos) | Enable Thanos add-on | `bool` | `false` | no |
| <a name="input_enable_traefik"></a> [enable\_traefik](#input\_enable\_traefik) | Enable Traefik add-on | `bool` | `false` | no |
| <a name="input_enable_vault"></a> [enable\_vault](#input\_enable\_vault) | Enable HashiCorp Vault add-on | `bool` | `false` | no |
| <a name="input_enable_velero"></a> [enable\_velero](#input\_enable\_velero) | Enable Kubernetes Dashboard add-on | `bool` | `false` | no |
| <a name="input_enable_vpa"></a> [enable\_vpa](#input\_enable\_vpa) | Enable Vertical Pod Autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_yunikorn"></a> [enable\_yunikorn](#input\_enable\_yunikorn) | Enable Apache YuniKorn K8s scheduler add-on | `bool` | `false` | no |
| <a name="input_external_dns_helm_config"></a> [external\_dns\_helm\_config](#input\_external\_dns\_helm\_config) | External DNS Helm Chart config | `any` | `{}` | no |
| <a name="input_external_dns_irsa_policies"></a> [external\_dns\_irsa\_policies](#input\_external\_dns\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_external_dns_private_zone"></a> [external\_dns\_private\_zone](#input\_external\_dns\_private\_zone) | Determines if referenced Route53 zone is private. | `bool` | `false` | no |
| <a name="input_external_dns_route53_zone_arns"></a> [external\_dns\_route53\_zone\_arns](#input\_external\_dns\_route53\_zone\_arns) | List of Route53 zones ARNs which external-dns will have access to create/manage records | `list(string)` | `[]` | no |
| <a name="input_external_secrets_helm_config"></a> [external\_secrets\_helm\_config](#input\_external\_secrets\_helm\_config) | External Secrets operator Helm Chart config | `any` | `{}` | no |
| <a name="input_external_secrets_irsa_policies"></a> [external\_secrets\_irsa\_policies](#input\_external\_secrets\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_external_secrets_secrets_manager_arns"></a> [external\_secrets\_secrets\_manager\_arns](#input\_external\_secrets\_secrets\_manager\_arns) | List of Secrets Manager ARNs that contain secrets to mount using External Secrets | `list(string)` | <pre>[<br>  "arn:aws:secretsmanager:*:*:secret:*"<br>]</pre> | no |
| <a name="input_external_secrets_ssm_parameter_arns"></a> [external\_secrets\_ssm\_parameter\_arns](#input\_external\_secrets\_ssm\_parameter\_arns) | List of Systems Manager Parameter ARNs that contain secrets to mount using External Secrets | `list(string)` | <pre>[<br>  "arn:aws:ssm:*:*:parameter/*"<br>]</pre> | no |
| <a name="input_fargate_fluentbit_addon_config"></a> [fargate\_fluentbit\_addon\_config](#input\_fargate\_fluentbit\_addon\_config) | Fargate fluentbit add-on config | `any` | `{}` | no |
| <a name="input_gatekeeper_helm_config"></a> [gatekeeper\_helm\_config](#input\_gatekeeper\_helm\_config) | Gatekeeper Helm Chart config | `any` | `{}` | no |
| <a name="input_grafana_helm_config"></a> [grafana\_helm\_config](#input\_grafana\_helm\_config) | Kubernetes Grafana Helm Chart config | `any` | `null` | no |
| <a name="input_grafana_irsa_policies"></a> [grafana\_irsa\_policies](#input\_grafana\_irsa\_policies) | IAM policy ARNs for grafana IRSA | `list(string)` | `[]` | no |
| <a name="input_ingress_nginx_helm_config"></a> [ingress\_nginx\_helm\_config](#input\_ingress\_nginx\_helm\_config) | Ingress Nginx Helm Chart config | `any` | `{}` | no |
| <a name="input_irsa_iam_permissions_boundary"></a> [irsa\_iam\_permissions\_boundary](#input\_irsa\_iam\_permissions\_boundary) | IAM permissions boundary for IRSA roles | `string` | `""` | no |
| <a name="input_irsa_iam_role_path"></a> [irsa\_iam\_role\_path](#input\_irsa\_iam\_role\_path) | IAM role path for IRSA roles | `string` | `"/"` | no |
| <a name="input_karpenter_helm_config"></a> [karpenter\_helm\_config](#input\_karpenter\_helm\_config) | Karpenter autoscaler add-on config | `any` | `{}` | no |
| <a name="input_karpenter_irsa_policies"></a> [karpenter\_irsa\_policies](#input\_karpenter\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_karpenter_node_iam_instance_profile"></a> [karpenter\_node\_iam\_instance\_profile](#input\_karpenter\_node\_iam\_instance\_profile) | Karpenter Node IAM Instance profile id | `string` | `""` | no |
| <a name="input_karpenter_sqs_queue_arn"></a> [karpenter\_sqs\_queue\_arn](#input\_karpenter\_sqs\_queue\_arn) | (Optional) ARN of SQS used by Karpenter when native node termination handling is enabled | `string` | `""` | no |
| <a name="input_keda_helm_config"></a> [keda\_helm\_config](#input\_keda\_helm\_config) | KEDA Event-based autoscaler add-on config | `any` | `{}` | no |
| <a name="input_keda_irsa_policies"></a> [keda\_irsa\_policies](#input\_keda\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_kube_prometheus_stack_helm_config"></a> [kube\_prometheus\_stack\_helm\_config](#input\_kube\_prometheus\_stack\_helm\_config) | Community kube-prometheus-stack Helm Chart config | `any` | `{}` | no |
| <a name="input_kubecost_helm_config"></a> [kubecost\_helm\_config](#input\_kubecost\_helm\_config) | Kubecost Helm Chart config | `any` | `{}` | no |
| <a name="input_kuberay_operator_helm_config"></a> [kuberay\_operator\_helm\_config](#input\_kuberay\_operator\_helm\_config) | KubeRay Operator Helm Chart config | `any` | `{}` | no |
| <a name="input_kubernetes_dashboard_helm_config"></a> [kubernetes\_dashboard\_helm\_config](#input\_kubernetes\_dashboard\_helm\_config) | Kubernetes Dashboard Helm Chart config | `any` | `null` | no |
| <a name="input_kyverno_helm_config"></a> [kyverno\_helm\_config](#input\_kyverno\_helm\_config) | Kyverno Helm Chart config | `any` | `{}` | no |
| <a name="input_kyverno_policies_helm_config"></a> [kyverno\_policies\_helm\_config](#input\_kyverno\_policies\_helm\_config) | Kyverno policies Helm Chart config | `any` | `{}` | no |
| <a name="input_kyverno_policy_reporter_helm_config"></a> [kyverno\_policy\_reporter\_helm\_config](#input\_kyverno\_policy\_reporter\_helm\_config) | Kyverno UI Helm Chart config | `any` | `{}` | no |
| <a name="input_local_volume_provisioner_helm_config"></a> [local\_volume\_provisioner\_helm\_config](#input\_local\_volume\_provisioner\_helm\_config) | Local volume provisioner Helm Chart config | `any` | `{}` | no |
| <a name="input_metrics_server_helm_config"></a> [metrics\_server\_helm\_config](#input\_metrics\_server\_helm\_config) | Metrics Server Helm Chart config | `any` | `{}` | no |
| <a name="input_nvidia_device_plugin_helm_config"></a> [nvidia\_device\_plugin\_helm\_config](#input\_nvidia\_device\_plugin\_helm\_config) | NVIDIA device plugin Helm Chart config | `any` | `{}` | no |
| <a name="input_ondat_admin_password"></a> [ondat\_admin\_password](#input\_ondat\_admin\_password) | Password for Ondat admin user | `string` | `"storageos"` | no |
| <a name="input_ondat_admin_username"></a> [ondat\_admin\_username](#input\_ondat\_admin\_username) | Username for Ondat admin user | `string` | `"storageos"` | no |
| <a name="input_ondat_create_cluster"></a> [ondat\_create\_cluster](#input\_ondat\_create\_cluster) | Create cluster resources | `bool` | `true` | no |
| <a name="input_ondat_etcd_ca"></a> [ondat\_etcd\_ca](#input\_ondat\_etcd\_ca) | CA content for Ondat etcd | `string` | `null` | no |
| <a name="input_ondat_etcd_cert"></a> [ondat\_etcd\_cert](#input\_ondat\_etcd\_cert) | Certificate content for Ondat etcd | `string` | `null` | no |
| <a name="input_ondat_etcd_endpoints"></a> [ondat\_etcd\_endpoints](#input\_ondat\_etcd\_endpoints) | List of etcd endpoints for Ondat | `list(string)` | `[]` | no |
| <a name="input_ondat_etcd_key"></a> [ondat\_etcd\_key](#input\_ondat\_etcd\_key) | Private key content for Ondat etcd | `string` | `null` | no |
| <a name="input_ondat_helm_config"></a> [ondat\_helm\_config](#input\_ondat\_helm\_config) | Ondat Helm Chart config | `any` | `{}` | no |
| <a name="input_ondat_irsa_policies"></a> [ondat\_irsa\_policies](#input\_ondat\_irsa\_policies) | IAM policy ARNs for Ondat IRSA | `list(string)` | `[]` | no |
| <a name="input_opentelemetry_operator_helm_config"></a> [opentelemetry\_operator\_helm\_config](#input\_opentelemetry\_operator\_helm\_config) | Opentelemetry Operator Helm Chart config | `any` | `{}` | no |
| <a name="input_portworx_helm_config"></a> [portworx\_helm\_config](#input\_portworx\_helm\_config) | Kubernetes Portworx Helm Chart config | `any` | `null` | no |
| <a name="input_prometheus_helm_config"></a> [prometheus\_helm\_config](#input\_prometheus\_helm\_config) | Community Prometheus Helm Chart config | `any` | `{}` | no |
| <a name="input_promtail_helm_config"></a> [promtail\_helm\_config](#input\_promtail\_helm\_config) | Promtail Helm Chart config | `any` | `{}` | no |
| <a name="input_reloader_helm_config"></a> [reloader\_helm\_config](#input\_reloader\_helm\_config) | Reloader Helm Chart config | `any` | `{}` | no |
| <a name="input_remove_default_coredns_deployment"></a> [remove\_default\_coredns\_deployment](#input\_remove\_default\_coredns\_deployment) | Determines whether the default deployment of CoreDNS is removed and ownership of kube-dns passed to Helm | `bool` | `false` | no |
| <a name="input_secrets_store_csi_driver_helm_config"></a> [secrets\_store\_csi\_driver\_helm\_config](#input\_secrets\_store\_csi\_driver\_helm\_config) | CSI Secrets Store Provider Helm Configurations | `any` | `null` | no |
| <a name="input_self_managed_aws_ebs_csi_driver_helm_config"></a> [self\_managed\_aws\_ebs\_csi\_driver\_helm\_config](#input\_self\_managed\_aws\_ebs\_csi\_driver\_helm\_config) | Self-managed aws-ebs-csi-driver Helm chart config | `any` | `{}` | no |
| <a name="input_self_managed_coredns_helm_config"></a> [self\_managed\_coredns\_helm\_config](#input\_self\_managed\_coredns\_helm\_config) | Self-managed CoreDNS Helm chart config | `any` | `{}` | no |
| <a name="input_smb_csi_driver_helm_config"></a> [smb\_csi\_driver\_helm\_config](#input\_smb\_csi\_driver\_helm\_config) | SMB CSI driver Helm Chart config | `any` | `{}` | no |
| <a name="input_spark_history_server_helm_config"></a> [spark\_history\_server\_helm\_config](#input\_spark\_history\_server\_helm\_config) | Spark History Server Helm Chart config | `any` | `{}` | no |
| <a name="input_spark_history_server_irsa_policies"></a> [spark\_history\_server\_irsa\_policies](#input\_spark\_history\_server\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_spark_history_server_s3a_path"></a> [spark\_history\_server\_s3a\_path](#input\_spark\_history\_server\_s3a\_path) | s3a path with prefix for Spark history server e.g., s3a://<bucket\_name>/<spark\_event\_logs> | `string` | `""` | no |
| <a name="input_spark_k8s_operator_helm_config"></a> [spark\_k8s\_operator\_helm\_config](#input\_spark\_k8s\_operator\_helm\_config) | Spark on K8s Operator Helm Chart config | `any` | `{}` | no |
| <a name="input_strimzi_kafka_operator_helm_config"></a> [strimzi\_kafka\_operator\_helm\_config](#input\_strimzi\_kafka\_operator\_helm\_config) | Kafka Strimzi Helm Chart config | `any` | `{}` | no |
| <a name="input_sysdig_agent_helm_config"></a> [sysdig\_agent\_helm\_config](#input\_sysdig\_agent\_helm\_config) | Sysdig Helm Chart config | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_tetrate_istio_base_helm_config"></a> [tetrate\_istio\_base\_helm\_config](#input\_tetrate\_istio\_base\_helm\_config) | Istio `base` Helm Chart config | `any` | `{}` | no |
| <a name="input_tetrate_istio_cni_helm_config"></a> [tetrate\_istio\_cni\_helm\_config](#input\_tetrate\_istio\_cni\_helm\_config) | Istio `cni` Helm Chart config | `any` | `{}` | no |
| <a name="input_tetrate_istio_distribution"></a> [tetrate\_istio\_distribution](#input\_tetrate\_istio\_distribution) | Istio distribution | `string` | `"TID"` | no |
| <a name="input_tetrate_istio_gateway_helm_config"></a> [tetrate\_istio\_gateway\_helm\_config](#input\_tetrate\_istio\_gateway\_helm\_config) | Istio `gateway` Helm Chart config | `any` | `{}` | no |
| <a name="input_tetrate_istio_install_base"></a> [tetrate\_istio\_install\_base](#input\_tetrate\_istio\_install\_base) | Install Istio `base` Helm Chart | `bool` | `true` | no |
| <a name="input_tetrate_istio_install_cni"></a> [tetrate\_istio\_install\_cni](#input\_tetrate\_istio\_install\_cni) | Install Istio `cni` Helm Chart | `bool` | `true` | no |
| <a name="input_tetrate_istio_install_gateway"></a> [tetrate\_istio\_install\_gateway](#input\_tetrate\_istio\_install\_gateway) | Install Istio `gateway` Helm Chart | `bool` | `true` | no |
| <a name="input_tetrate_istio_install_istiod"></a> [tetrate\_istio\_install\_istiod](#input\_tetrate\_istio\_install\_istiod) | Install Istio `istiod` Helm Chart | `bool` | `true` | no |
| <a name="input_tetrate_istio_istiod_helm_config"></a> [tetrate\_istio\_istiod\_helm\_config](#input\_tetrate\_istio\_istiod\_helm\_config) | Istio `istiod` Helm Chart config | `any` | `{}` | no |
| <a name="input_tetrate_istio_version"></a> [tetrate\_istio\_version](#input\_tetrate\_istio\_version) | Istio version | `string` | `""` | no |
| <a name="input_thanos_helm_config"></a> [thanos\_helm\_config](#input\_thanos\_helm\_config) | Thanos Helm Chart config | `any` | `{}` | no |
| <a name="input_thanos_irsa_policies"></a> [thanos\_irsa\_policies](#input\_thanos\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_traefik_helm_config"></a> [traefik\_helm\_config](#input\_traefik\_helm\_config) | Traefik Helm Chart config | `any` | `{}` | no |
| <a name="input_vault_helm_config"></a> [vault\_helm\_config](#input\_vault\_helm\_config) | HashiCorp Vault Helm Chart config | `any` | `null` | no |
| <a name="input_velero_backup_s3_bucket"></a> [velero\_backup\_s3\_bucket](#input\_velero\_backup\_s3\_bucket) | Bucket name for velero bucket | `string` | `""` | no |
| <a name="input_velero_helm_config"></a> [velero\_helm\_config](#input\_velero\_helm\_config) | Kubernetes Velero Helm Chart config | `any` | `null` | no |
| <a name="input_velero_irsa_policies"></a> [velero\_irsa\_policies](#input\_velero\_irsa\_policies) | IAM policy ARNs for velero IRSA | `list(string)` | `[]` | no |
| <a name="input_vpa_helm_config"></a> [vpa\_helm\_config](#input\_vpa\_helm\_config) | VPA Helm Chart config | `any` | `null` | no |
| <a name="input_yunikorn_helm_config"></a> [yunikorn\_helm\_config](#input\_yunikorn\_helm\_config) | YuniKorn Helm Chart config | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_adot_collector_haproxy"></a> [adot\_collector\_haproxy](#output\_adot\_collector\_haproxy) | Map of attributes of the Helm release and IRSA created |
| <a name="output_adot_collector_java"></a> [adot\_collector\_java](#output\_adot\_collector\_java) | Map of attributes of the Helm release and IRSA created |
| <a name="output_adot_collector_memcached"></a> [adot\_collector\_memcached](#output\_adot\_collector\_memcached) | Map of attributes of the Helm release and IRSA created |
| <a name="output_adot_collector_nginx"></a> [adot\_collector\_nginx](#output\_adot\_collector\_nginx) | Map of attributes of the Helm release and IRSA created |
| <a name="output_agones"></a> [agones](#output\_agones) | Map of attributes of the Helm release and IRSA created |
| <a name="output_airflow"></a> [airflow](#output\_airflow) | Map of attributes of the Helm release and IRSA created |
| <a name="output_appmesh_controller"></a> [appmesh\_controller](#output\_appmesh\_controller) | Map of attributes of the Helm release and IRSA created |
| <a name="output_argo_rollouts"></a> [argo\_rollouts](#output\_argo\_rollouts) | Map of attributes of the Helm release and IRSA created |
| <a name="output_argo_workflows"></a> [argo\_workflows](#output\_argo\_workflows) | Map of attributes of the Helm release and IRSA created |
| <a name="output_argocd"></a> [argocd](#output\_argocd) | Map of attributes of the Helm release and IRSA created |
| <a name="output_aws_cloudwatch_metrics"></a> [aws\_cloudwatch\_metrics](#output\_aws\_cloudwatch\_metrics) | Map of attributes of the Helm release and IRSA created |
| <a name="output_aws_coredns"></a> [aws\_coredns](#output\_aws\_coredns) | Map of attributes of the Helm release and IRSA created |
| <a name="output_aws_ebs_csi_driver"></a> [aws\_ebs\_csi\_driver](#output\_aws\_ebs\_csi\_driver) | Map of attributes of the Helm release and IRSA created |
| <a name="output_aws_efs_csi_driver"></a> [aws\_efs\_csi\_driver](#output\_aws\_efs\_csi\_driver) | Map of attributes of the Helm release and IRSA created |
| <a name="output_aws_for_fluent_bit"></a> [aws\_for\_fluent\_bit](#output\_aws\_for\_fluent\_bit) | Map of attributes of the Helm release and IRSA created |
| <a name="output_aws_fsx_csi_driver"></a> [aws\_fsx\_csi\_driver](#output\_aws\_fsx\_csi\_driver) | Map of attributes of the Helm release and IRSA created |
| <a name="output_aws_kube_proxy"></a> [aws\_kube\_proxy](#output\_aws\_kube\_proxy) | Map of attributes of the Helm release and IRSA created |
| <a name="output_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#output\_aws\_load\_balancer\_controller) | Map of attributes of the Helm release and IRSA created |
| <a name="output_aws_node_termination_handler"></a> [aws\_node\_termination\_handler](#output\_aws\_node\_termination\_handler) | Map of attributes of the Helm release and IRSA created |
| <a name="output_aws_privateca_issuer"></a> [aws\_privateca\_issuer](#output\_aws\_privateca\_issuer) | Map of attributes of the Helm release and IRSA created |
| <a name="output_aws_vpc_cni"></a> [aws\_vpc\_cni](#output\_aws\_vpc\_cni) | Map of attributes of the Helm release and IRSA created |
| <a name="output_calico"></a> [calico](#output\_calico) | Map of attributes of the Helm release and IRSA created |
| <a name="output_cert_manager"></a> [cert\_manager](#output\_cert\_manager) | Map of attributes of the Helm release and IRSA created |
| <a name="output_cert_manager_csi_driver"></a> [cert\_manager\_csi\_driver](#output\_cert\_manager\_csi\_driver) | Map of attributes of the Helm release and IRSA created |
| <a name="output_cert_manager_istio_csr"></a> [cert\_manager\_istio\_csr](#output\_cert\_manager\_istio\_csr) | Map of attributes of the Helm release and IRSA created |
| <a name="output_chaos_mesh"></a> [chaos\_mesh](#output\_chaos\_mesh) | Map of attributes of the Helm release and IRSA created |
| <a name="output_cilium"></a> [cilium](#output\_cilium) | Map of attributes of the Helm release and IRSA created |
| <a name="output_cluster_autoscaler"></a> [cluster\_autoscaler](#output\_cluster\_autoscaler) | Map of attributes of the Helm release and IRSA created |
| <a name="output_coredns_autoscaler"></a> [coredns\_autoscaler](#output\_coredns\_autoscaler) | Map of attributes of the Helm release and IRSA created |
| <a name="output_crossplane"></a> [crossplane](#output\_crossplane) | Map of attributes of the Helm release and IRSA created |
| <a name="output_csi_secrets_store_provider_aws"></a> [csi\_secrets\_store\_provider\_aws](#output\_csi\_secrets\_store\_provider\_aws) | Map of attributes of the Helm release and IRSA created |
| <a name="output_datadog_operator"></a> [datadog\_operator](#output\_datadog\_operator) | Map of attributes of the Helm release and IRSA created |
| <a name="output_emr_on_eks"></a> [emr\_on\_eks](#output\_emr\_on\_eks) | EMR on EKS |
| <a name="output_external_dns"></a> [external\_dns](#output\_external\_dns) | Map of attributes of the Helm release and IRSA created |
| <a name="output_external_secrets"></a> [external\_secrets](#output\_external\_secrets) | Map of attributes of the Helm release and IRSA created |
| <a name="output_fargate_fluentbit"></a> [fargate\_fluentbit](#output\_fargate\_fluentbit) | Map of attributes of the Helm release and IRSA created |
| <a name="output_gatekeeper"></a> [gatekeeper](#output\_gatekeeper) | Map of attributes of the Helm release and IRSA created |
| <a name="output_grafana"></a> [grafana](#output\_grafana) | Map of attributes of the Helm release and IRSA created |
| <a name="output_ingress_nginx"></a> [ingress\_nginx](#output\_ingress\_nginx) | Map of attributes of the Helm release and IRSA created |
| <a name="output_karpenter"></a> [karpenter](#output\_karpenter) | Map of attributes of the Helm release and IRSA created |
| <a name="output_keda"></a> [keda](#output\_keda) | Map of attributes of the Helm release and IRSA created |
| <a name="output_kube_prometheus_stack"></a> [kube\_prometheus\_stack](#output\_kube\_prometheus\_stack) | Map of attributes of the Helm release and IRSA created |
| <a name="output_kubecost"></a> [kubecost](#output\_kubecost) | Map of attributes of the Helm release and IRSA created |
| <a name="output_kuberay_operator"></a> [kuberay\_operator](#output\_kuberay\_operator) | Map of attributes of the Helm release and IRSA created |
| <a name="output_kubernetes_dashboard"></a> [kubernetes\_dashboard](#output\_kubernetes\_dashboard) | Map of attributes of the Helm release and IRSA created |
| <a name="output_kyverno"></a> [kyverno](#output\_kyverno) | Map of attributes of the Helm release and IRSA created |
| <a name="output_local_volume_provisioner"></a> [local\_volume\_provisioner](#output\_local\_volume\_provisioner) | Map of attributes of the Helm release and IRSA created |
| <a name="output_metrics_server"></a> [metrics\_server](#output\_metrics\_server) | Map of attributes of the Helm release and IRSA created |
| <a name="output_nvidia_device_plugin"></a> [nvidia\_device\_plugin](#output\_nvidia\_device\_plugin) | Map of attributes of the Helm release and IRSA created |
| <a name="output_opentelemetry_operator"></a> [opentelemetry\_operator](#output\_opentelemetry\_operator) | Map of attributes of the Helm release and IRSA created |
| <a name="output_prometheus"></a> [prometheus](#output\_prometheus) | Map of attributes of the Helm release and IRSA created |
| <a name="output_promtail"></a> [promtail](#output\_promtail) | Map of attributes of the Helm release and IRSA created |
| <a name="output_reloader"></a> [reloader](#output\_reloader) | Map of attributes of the Helm release and IRSA created |
| <a name="output_secrets_store_csi_driver"></a> [secrets\_store\_csi\_driver](#output\_secrets\_store\_csi\_driver) | Map of attributes of the Helm release and IRSA created |
| <a name="output_smb_csi_driver"></a> [smb\_csi\_driver](#output\_smb\_csi\_driver) | Map of attributes of the Helm release and IRSA created |
| <a name="output_spark_history_server"></a> [spark\_history\_server](#output\_spark\_history\_server) | Map of attributes of the Helm release and IRSA created |
| <a name="output_spark_k8s_operator"></a> [spark\_k8s\_operator](#output\_spark\_k8s\_operator) | Map of attributes of the Helm release and IRSA created |
| <a name="output_strimzi_kafka_operator"></a> [strimzi\_kafka\_operator](#output\_strimzi\_kafka\_operator) | Map of attributes of the Helm release and IRSA created |
| <a name="output_thanos"></a> [thanos](#output\_thanos) | Map of attributes of the Helm release and IRSA created |
| <a name="output_traefik"></a> [traefik](#output\_traefik) | Map of attributes of the Helm release and IRSA created |
| <a name="output_velero"></a> [velero](#output\_velero) | Map of attributes of the Helm release and IRSA created |
| <a name="output_vpa"></a> [vpa](#output\_vpa) | Map of attributes of the Helm release and IRSA created |
| <a name="output_yunikorn"></a> [yunikorn](#output\_yunikorn) | Map of attributes of the Helm release and IRSA created |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
