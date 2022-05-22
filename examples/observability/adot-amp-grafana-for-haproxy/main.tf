provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
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
      api_version = "client.authentication.k8s.io/v1alpha1"
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
  tenant      = var.tenant      # AWS account name or unique id for tenant
  environment = var.environment # Environment area eg., preprod or prod
  zone        = var.zone        # Environment within one sub_tenant or business unit

  region = "us-east-1"
  azs    = slice(data.aws_availability_zones.available.names, 0, 3)

  cluster_version = "1.21"
  cluster_name    = join("-", [local.tenant, local.environment, local.zone, "eks"])

  vpc_cidr = "10.0.0.0/16"
  vpc_name = join("-", [local.tenant, local.environment, local.zone, "vpc"])

  terraform_version = "Terraform v1.1.7"
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

#---------------------------------------------------------------
# Provision EKS and Helm Charts
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "../../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS Control Plane Variables
  cluster_version = local.cluster_version

  managed_node_groups = {
    t3_l = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.large"]
      min_size        = 2
      subnet_ids      = module.aws_vpc.private_subnets
    }
  }

  # Provisions a new Amazon Managed Service for Prometheus workspace
  enable_amazon_prometheus = true
}

module "eks_blueprints_kubernetes_addons" {
  source         = "../../../modules/kubernetes-addons"
  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  # OTEL JMX use cases
  enable_cert_manager                  = true
  enable_opentelemetry_operator        = true
  enable_adot_collector_haproxy        = true
  amazon_prometheus_workspace_endpoint = module.eks_blueprints.amazon_prometheus_workspace_endpoint
  amazon_prometheus_workspace_region   = local.region
}

# Configure HAProxy default Grafana dashboards
resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "amp"
  is_default = true
  url        = module.eks_blueprints.amazon_prometheus_workspace_endpoint
  json_data {
    http_method     = "GET"
    sigv4_auth      = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region    = local.region
  }
}

resource "grafana_folder" "haproxy_dashboards" {
  title = "Observability"
}

resource "grafana_dashboard" "haproxy_dashboards" {
  folder      = grafana_folder.haproxy_dashboards.id
  config_json = file("${path.module}/dashboards/default.json")
}

resource "aws_prometheus_rule_group_namespace" "haproxy" {
  name         = "haproxy_rules"
  workspace_id = module.eks_blueprints.amazon_prometheus_workspace_id

  data = <<-EOF
  groups:
    - name: obsa-haproxy-down-alert
      rules:
      - alert: HA_proxy_down
      expr: haproxy_up == 0
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: HAProxy down (instance {{ $labels.instance }})
        description: "HAProxy down\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - name: obsa-haproxy-http4xx-error-alert
      rules:
      - alert: Ha_proxy_High_Http4xx_ErrorRate_Backend
      expr: sum by (backend) (rate(haproxy_server_http_responses_total{code="4xx"}[1m])) / sum by (backend) (rate(haproxy_server_http_responses_total[1m]) * 100) > 5
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: HAProxy high HTTP 4xx error rate backend (instance {{ $labels.instance }})
        description: "Too many HTTP requests with status 4xx (> 5%) on backend {{ $labels.fqdn }}/{{ $labels.backend }}\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - name: obsa-haproxy-http4xx-error-alert
      rules:
      - alert: Ha_proxy_High_Http5xx_ErrorRate_Backend
      expr: sum by (backend) (rate(haproxy_server_http_responses_total{code="5xx"}[1m])) / sum by (backend) (rate(haproxy_server_http_responses_total[1m]) * 100) > 5
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: HAProxy high HTTP 5xx error rate backend (instance {{ $labels.instance }})
        description: "Too many HTTP requests with status 5xx (> 5%) on backend {{ $labels.fqdn }}/{{ $labels.backend }}\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - name: obsa-haproxy-Http4xx-ErrorRate-Server-alert
      rules:
      - alert: Ha_proxy_High_Http4xx_ErrorRate_Server
      expr: sum by (server) (rate(haproxy_server_http_responses_total{code="4xx"}[1m])) / sum by (server) (rate(haproxy_server_http_responses_total[1m]) * 100) > 5
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: HAProxy high HTTP 4xx error rate server (instance {{ $labels.instance }})
        description: "Too many HTTP requests with status 4xx (> 5%) on server {{ $labels.server }}\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

    - name: obsa-haproxy-Http5xx-ErrorRate-Server-alert
      rules:
      - alert: Ha_proxy_High_Http5xx_ErrorRate_Server
      expr: sum by (server) (rate(haproxy_server_http_responses_total{code="5xx"}[1m])) / sum by (server) (rate(haproxy_server_http_responses_total[1m]) * 100) > 5
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: HAProxy high HTTP 5xx error rate server (instance {{ $labels.instance }})
        description: "Too many HTTP requests with status 5xx (> 5%) on server {{ $labels.server }}\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
  EOF
}

resource "aws_prometheus_alert_manager_definition" "haproxy" {
  workspace_id = module.eks_blueprints.amazon_prometheus_workspace_id

  definition = <<-EOF
  alertmanager_config: |
    route:
      receiver: 'default'
    receivers:
      - name: 'default'
  EOF
}
