output "adot_collector_haproxy" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.adot_collector_haproxy[0], null)
}

output "adot_collector_java" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.adot_collector_java[0], null)
}

output "adot_collector_memcached" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.adot_collector_memcached[0], null)
}

output "adot_collector_nginx" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.adot_collector_nginx[0], null)
}

output "agones" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.agones[0], null)
}

output "airflow" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.airflow[0], null)
}

output "appmesh_controller" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.appmesh_controller[0], null)
}

output "argocd" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.argocd[0], null)
}

output "argo_rollouts" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.argo_rollouts[0], null)
}

output "argo_workflows" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.argo_workflows[0], null)
}

output "aws_cloudwatch_metrics" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.aws_cloudwatch_metrics[0], null)
}

output "aws_coredns" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.aws_coredns[0], null)
}

output "aws_ebs_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.aws_ebs_csi_driver[0], null)
}

output "aws_efs_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.aws_efs_csi_driver[0], null)
}

output "aws_for_fluent_bit" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.aws_for_fluent_bit[0], null)
}

output "aws_fsx_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.aws_fsx_csi_driver[0], null)
}

output "aws_kube_proxy" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.aws_kube_proxy[0], null)
}

output "aws_load_balancer_controller" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.aws_load_balancer_controller[0], null)
}

output "aws_node_termination_handler" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.aws_node_termination_handler[0], null)
}

output "aws_privateca_issuer" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.aws_privateca_issuer[0], null)
}

output "aws_vpc_cni" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.aws_vpc_cni[0], null)
}

output "calico" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.calico[0], null)
}

output "cert_manager" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.cert_manager[0], null)
}

output "cert_manager_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.cert_manager_csi_driver[0], null)
}

output "cert_manager_istio_csr" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.cert_manager_istio_csr[0], null)
}

output "chaos_mesh" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.chaos_mesh[0], null)
}

output "cilium" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.cilium[0], null)
}

output "cluster_autoscaler" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.cluster_autoscaler[0], null)
}

output "coredns_autoscaler" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.coredns_autoscaler[0], null)
}

output "crossplane" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.crossplane[0], null)
}

output "csi_secrets_store_provider_aws" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.csi_secrets_store_provider_aws[0], null)
}

output "datadog_operator" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.datadog_operator[0], null)
}

output "external_dns" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.external_dns[0], null)
}

output "external_secrets" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.external_secrets[0], null)
}

output "fargate_fluentbit" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.fargate_fluentbit[0], null)
}

output "gatekeeper" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.gatekeeper[0], null)
}

output "grafana" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.grafana[0], null)
}

output "ingress_nginx" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.ingress_nginx[0], null)
}

output "karpenter" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.karpenter[0], null)
}

output "keda" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.keda[0], null)
}

output "kubecost" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.kubecost[0], null)
}

output "kube_prometheus_stack" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.kube_prometheus_stack[0], null)
}

output "kuberay_operator" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.kuberay_operator[0], null)
}

output "kubernetes_dashboard" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.kubernetes_dashboard[0], null)
}

output "kyverno" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.kyverno[0], null)
}

output "local_volume_provisioner" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.local_volume_provisioner[0], null)
}

output "metrics_server" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.metrics_server[0], null)
}

output "nvidia_device_plugin" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.nvidia_device_plugin[0], null)
}

output "opentelemetry_operator" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.opentelemetry_operator[0], null)
}

output "prometheus" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.prometheus[0], null)
}

output "promtail" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.promtail[0], null)
}

output "reloader" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.reloader[0], null)
}

output "secrets_store_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.secrets_store_csi_driver[0], null)
}

output "smb_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.smb_csi_driver[0], null)
}

output "spark_history_server" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.spark_history_server[0], null)
}

output "spark_k8s_operator" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.spark_k8s_operator[0], null)
}

output "strimzi_kafka_operator" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.strimzi_kafka_operator[0], null)
}

output "thanos" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.thanos[0], null)
}

output "traefik" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.traefik[0], null)
}

output "velero" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.velero[0], null)
}

output "vpa" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.vpa[0], null)
}

output "yunikorn" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.yunikorn[0], null)
}

output "emr_on_eks" {
  description = "EMR on EKS"
  value       = module.emr_on_eks
}
