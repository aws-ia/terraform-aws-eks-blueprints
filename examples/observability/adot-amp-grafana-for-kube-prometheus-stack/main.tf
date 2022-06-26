provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

provider "grafana" {
  url  = var.grafana_endpoint
  auth = var.grafana_api_key
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = var.aws_region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "../../.."

  cluster_name    = local.name
  cluster_version = "1.22"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    t3_l = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.large"]
      min_size        = 2
      subnet_ids      = module.vpc.private_subnets
    }
  }

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # enable AWS Managed EKS add-on for ADOT
  enable_amazon_eks_adot = true
  # or enable a customer-managed OpenTelemetry operator
  # enable_opentelemetry_operator = true
  enable_adot_collector_java = true

  amazon_prometheus_workspace_endpoint = module.managed_prometheus.workspace_prometheus_endpoint
  amazon_prometheus_workspace_region   = local.region

  tags = local.tags
}

#---------------------------------------------------------------
# Observability Resources
#---------------------------------------------------------------

module "managed_grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 1.3"

  # Workspace
  name              = local.name
  stack_set_name    = local.name
  data_sources      = ["PROMETHEUS"]
  associate_license = false

  # # Role associations
  # Pending https://github.com/hashicorp/terraform-provider-aws/issues/24166
  # role_associations = {
  #   "ADMIN" = {
  #     "group_ids" = []
  #     "user_ids"  = []
  #   }
  #   "EDITOR" = {
  #     "group_ids" = []
  #     "user_ids"  = []
  #   }
  # }

  tags = local.tags
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "amp"
  is_default = true
  url        = module.managed_prometheus.workspace_prometheus_endpoint

  json_data {
    http_method     = "GET"
    sigv4_auth      = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region    = local.region
  }
}

resource "grafana_folder" "this" {
  title = "Observability"
}

resource "grafana_dashboard" "this" {
  folder      = grafana_folder.this.id
  config_json = file("${path.module}/dashboards/*.json")
}

module "managed_prometheus" {
  source  = "terraform-aws-modules/managed-service-prometheus/aws"
  version = "~> 2.1"

  workspace_alias = local.name

  alert_manager_definition = <<-EOT
  alertmanager_config: |
    route:
      receiver: 'default'
    receivers:
      - name: 'default'
  EOT

  rule_group_namespaces = {
    api-server = {
      name = "api-rules"
      data = <<-EOT
      groups:
        - name: api-01
          rules:
            - record: code_verb:apiserver_request_total:increase30d
              expr: avg_over_time(code_verb:apiserver_request_total:increase1h[30d]) * 24 * 30
        - name: api-02
          rules:
            - record: code:apiserver_request_total:increase30d
              expr: sum by(cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~"LIST|GET"})
              labels:
                 verb: read
        - name: api-03
          rules:
            - record: code:apiserver_request_total:increase30d
              expr: sum by(cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~"POST|PUT|PATCH|DELETE"})
              labels:
                 verb: write
        - name: api-04
          rules:
            - record: cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase1h
              expr: sum by(cluster, verb, scope) (increase(apiserver_request_slo_duration_seconds_count[1h]))
        - name: api-05
          rules:
            - record: cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase30d
              expr: sum by(cluster, verb, scope) (avg_over_time(cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase1h[30d]) * 24 * 30)
      EOT
    }
    kube-prometheus-stack = {
      name = "General_rules"
      data = <<-EOT
      groups:
        - name: k8s-01
          rules:
            - record: node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate
              expr: sum by(cluster, namespace, pod, container) (irate(container_cpu_usage_seconds_total{image!="",job="kubelet",metrics_path="/metrics/cadvisor"}[5m])) * on(cluster, namespace, pod) group_left(node) topk by(cluster, namespace, pod) (1, max by(cluster, namespace, pod, node) (kube_pod_info{node!=""}))
        
        - name: k8s-02
          rules:
            - record: node_namespace_pod_container:container_memory_working_set_bytes
              expr: container_memory_working_set_bytes{image!="",job="kubelet",metrics_path="/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
        - name: k8s-03
          rules:
            - record: node_namespace_pod_container:container_memory_rss
              expr: container_memory_rss{image!="",job="kubelet",metrics_path="/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
        - name: k8s-04
          rules:
            - record: node_namespace_pod_container:container_memory_cache
              expr: container_memory_cache{image!="",job="kubelet",metrics_path="/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
        - name: k8s-05
          rules:
            - record: node_namespace_pod_container:container_memory_swap
              expr: container_memory_swap{image!="",job="kubelet",metrics_path="/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
        - name: k8s-06
          rules:
            - record: cluster:namespace:pod_memory:active:kube_pod_container_resource_requests
              expr: kube_pod_container_resource_requests{job="kube-state-metrics",resource="memory"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
        - name: k8s-07
          rules:
            - record: namespace_memory:kube_pod_container_resource_requests:sum
              expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_requests{job="kube-state-metrics",resource="memory"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))
        - name: k8s-08
          rules:
            - record: cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests
              expr: kube_pod_container_resource_requests{job="kube-state-metrics",resource="cpu"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
        - name: k8s-09
          rules:
            - record: namespace_cpu:kube_pod_container_resource_requests:sum
              expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_requests{job="kube-state-metrics",resource="cpu"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))  
        - name: k8s-10
          rules:
            - record: cluster:namespace:pod_memory:active:kube_pod_container_resource_limits
              expr: kube_pod_container_resource_limits{job="kube-state-metrics",resource="memory"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
        - name: k8s-11
          rules:
            - record: namespace_memory:kube_pod_container_resource_limits:sum
              expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_limits{job="kube-state-metrics",resource="memory"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))
        - name: k8s-12
          rules:
            - record: cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits
              expr: kube_pod_container_resource_limits{job="kube-state-metrics",resource="cpu"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
        - name: k8s-13
          rules:
            - record: namespace_cpu:kube_pod_container_resource_limits:sum
              expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_limits{job="kube-state-metrics",resource="cpu"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))
        - name: k8s-14
          rules:
            - record: namespace_workload_pod:kube_pod_owner:relabel
              expr: max by(cluster, namespace, workload, pod) (label_replace(label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="ReplicaSet"}, "replicaset", "$1", "owner_name", "(.*)") * on(replicaset, namespace) group_left(owner_name) topk by(replicaset, namespace) (1, max by(replicaset, namespace, owner_name) (kube_replicaset_owner{job="kube-state-metrics"})), "workload", "$1", "owner_name", "(.*)"))
              labels:
                 workload_type: deployment
        - name: k8s-15
          rules:
            - record: namespace_workload_pod:kube_pod_owner:relabel
              expr: max by(cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="DaemonSet"}, "workload", "$1", "owner_name", "(.*)"))
              labels:
                 workload_type: daemonset
        - name: k8s-16
          rules:
            - record: namespace_workload_pod:kube_pod_owner:relabel
              expr: max by(cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="StatefulSet"}, "workload", "$1", "owner_name", "(.*)"))
              labels:
                 workload_type: statefulset
        - name: k8s-17
          rules:
            - record: namespace_workload_pod:kube_pod_owner:relabel
              expr: max by(cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="Job"}, "workload", "$1", "owner_name", "(.*)"))
              labels:
                 workload_type: job
      EOT
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}
