provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "grafana" {
  url  = try(var.grafana_endpoint, "https://${module.managed_grafana.workspace_endpoint}")
  auth = var.grafana_api_key
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
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
  cluster_version = "1.24"

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
  enable_adot_collector_nginx = true

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
  config_json = file("${path.module}/dashboards/default.json")
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
    nginx = {
      name = "nginx_rules"
      data = <<-EOT
      groups:
        - name: Nginx-HTTP-4xx-error-rate
          rules:
          - alert: metric:alerting_rule
            expr: sum(rate(nginx_http_requests_total{status=~"^4.."}[1m])) / sum(rate(nginx_http_requests_total[1m])) * 100 > 5
            for: 1m
            labels:
             severity: critical
            annotations:
             summary: Nginx high HTTP 4xx error rate (instance {{ $labels.instance }})
             description: "Too many HTTP requests with status 4xx (> 5%)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
        - name: Nginx-HTTP-5xx-error-rate
          rules:
          - alert: metric:alerting_rule
            expr: sum(rate(nginx_http_requests_total{status=~"^5.."}[1m])) / sum(rate(nginx_http_requests_total[1m])) * 100 > 5
            for: 1m
            labels:
             severity: critical
            annotations:
             summary: Nginx high HTTP 5xx error rate (instance {{ $labels.instance }})
             description: "Too many HTTP requests with status 5xx (> 5%)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
        - name: Nginx-high-latency
          rules:
          - alert: metric:alerting_rule
            expr: histogram_quantile(0.99, sum(rate(nginx_http_request_duration_seconds_bucket[2m])) by (host, node)) > 3
            for: 2m
            labels:
             severity: warning
            annotations:
             summary: Nginx latency high (instance {{ $labels.instance }})
             description: "Nginx p99 latency is higher than 3 seconds\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
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
