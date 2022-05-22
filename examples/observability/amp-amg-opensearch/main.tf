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
  tenant      = "aws001"        # AWS account name or unique id for tenant
  environment = "preprod"       # Environment area eg., preprod or prod
  zone        = "observability" # Environment within one sub_tenant or business unit
  region      = "us-west-2"

  vpc_cidr     = "10.0.0.0/16"
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.1.4"
}

#---------------------------------------------------------------
# Networking
#---------------------------------------------------------------
module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

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
  cluster_version = "1.21"

  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.xlarge"]
      min_size        = 3
      subnet_ids      = module.aws_vpc.private_subnets
    }
  }

  # Provisions a new Amazon Managed Service for Prometheus workspace
  enable_amazon_prometheus = true
}

module "eks_blueprints_kubernetes_addons" {
  source         = "../../../modules/kubernetes-addons"
  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  #K8s Add-ons
  enable_metrics_server     = true
  enable_cluster_autoscaler = true
  enable_argocd             = true
  argocd_applications = {
    workloads = {
      path               = "envs/dev"
      repo_url           = "https://github.com/aws-samples/eks-blueprints-workloads.git"
      add_on_application = false
    }
  }

  # Fluentbit
  enable_aws_for_fluentbit        = true
  aws_for_fluentbit_irsa_policies = [aws_iam_policy.fluentbit_opensearch_access.arn]
  aws_for_fluentbit_helm_config = {
    values = [templatefile("${path.module}/helm_values/aws-for-fluentbit-values.yaml", {
      aws_region = local.region
      host       = aws_elasticsearch_domain.opensearch.endpoint
    })]
  }

  # Prometheus and Amazon Managed Prometheus integration
  enable_prometheus                    = true
  enable_amazon_prometheus             = true
  amazon_prometheus_workspace_endpoint = module.eks_blueprints.amazon_prometheus_workspace_endpoint

  depends_on = [
    module.eks_blueprints.managed_node_groups,
    module.aws_vpc
  ]
}

#---------------------------------------------------------------
# Configure AMP as a Grafana Data Source
#---------------------------------------------------------------
resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "amp"
  is_default = true
  url        = module.eks_blueprints.amazon_prometheus_workspace_endpoint

  json_data {
    http_method     = "POST"
    sigv4_auth      = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region    = local.region
  }
}

#---------------------------------------------------------------
# Provision OpenSearch and Allow Access
#---------------------------------------------------------------
#tfsec:ignore:aws-elastic-search-enable-domain-logging
resource "aws_elasticsearch_domain" "opensearch" {
  domain_name           = "opensearch"
  elasticsearch_version = "OpenSearch_1.1"

  cluster_config {
    instance_type          = "m4.large.elasticsearch"
    instance_count         = 3
    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = 3
    }
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  encrypt_at_rest {
    enabled = true
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = var.opensearch_dashboard_user
      master_user_password = var.opensearch_dashboard_pw
    }
  }

  vpc_options {
    subnet_ids         = module.aws_vpc.public_subnets
    security_group_ids = [aws_security_group.opensearch_access.id]
  }

  depends_on = [
    aws_iam_service_linked_role.opensearch
  ]
}

resource "aws_iam_service_linked_role" "opensearch" {
  count            = var.create_iam_service_linked_role == true ? 1 : 0
  aws_service_name = "es.amazonaws.com"
}

resource "aws_iam_policy" "fluentbit_opensearch_access" {
  name        = "fluentbit_opensearch_access"
  description = "IAM policy to allow Fluentbit access to OpenSearch"
  policy      = data.aws_iam_policy_document.fluentbit_opensearch_access.json
}

resource "aws_elasticsearch_domain_policy" "opensearch_access_policy" {
  domain_name     = aws_elasticsearch_domain.opensearch.domain_name
  access_policies = data.aws_iam_policy_document.opensearch_access_policy.json
}

resource "aws_security_group" "opensearch_access" {
  vpc_id      = module.aws_vpc.vpc_id
  description = "OpenSearch access"

  ingress {
    description = "host access to OpenSearch"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "allow instances in the VPC (like EKS) to communicate with OpenSearch"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    description = "Allow all outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  }
}
