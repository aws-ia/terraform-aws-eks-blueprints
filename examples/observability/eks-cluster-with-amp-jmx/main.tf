terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.73.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.13.3"
    }
  }

  backend "local" {
    path = "local_tf_state/terraform-main.tfstate"
  }
}

locals {
  tenant      = "aws001"        # AWS account name or unique id for tenant
  environment = "preprod"       # Environment area eg., preprod or prod
  zone        = "observability" # Environment within one sub_tenant or business unit

  kubernetes_version = "1.21"

  vpc_cidr     = "10.0.0.0/16"
  vpc_name     = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.1.7"

  # Sample workload managed by ArgoCD. For generating metrics and logs
  workload_application = {
    path               = "envs/dev"
    repo_url           = "https://github.com/aws-samples/ssp-eks-workloads.git"
    add_on_application = false
  }

  aws_iam_instance_profile_name = "bastion_host_profile"
}

#---------------------------------------------------------------
# Networking
#---------------------------------------------------------------
module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.11.3"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = data.aws_availability_zones.available.names

  public_subnets  = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(local.vpc_cidr, 8, k + 10)]

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
module "aws-eks-accelerator-for-terraform" {
  source = "../../.."

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS Control Plane Variables
  create_eks         = true
  kubernetes_version = local.kubernetes_version

  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.large"]
      min_size        = 2
      subnet_ids      = module.aws_vpc.private_subnets
    }
  }

  # Provisions a new Amazon Managed Service for Prometheus workspace
  enable_amazon_prometheus = true
}

module "kubernetes-addons" {
  source         = "../../../modules/kubernetes-addons"
  eks_cluster_id = module.aws-eks-accelerator-for-terraform.eks_cluster_id


  # OTEL JMX use cases
  enable_otel_operator_jmx = true

  otel_operator_jmx_config = {
    amazon_prometheus_remote_write_url = module.aws-eks-accelerator-for-terraform.amazon_prometheus_workspace_endpoint
    # Override this if you want to send metrics data to a workspace in a different region
    amazon_prometheus_region = data.aws_region.current.name

    // config map: ports, region, customer managed amp
  }

}

#---------------------------------------------------------------
# Configure AMP as a Grafana Data Source
#---------------------------------------------------------------
resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "amp"
  is_default = true
  url        = module.aws-eks-accelerator-for-terraform.amazon_prometheus_workspace_endpoint
  json_data {
    http_method     = "POST"
    sigv4_auth      = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region    = data.aws_region.current.name
  }
}
#---------------------------------------------------------------
# Configure JMX default Grafana dashboards
#---------------------------------------------------------------
resource "grafana_folder" "jmx_dashboards" {
  title = "JMX Dashboards"

  depends_on = [module.kubernetes-addons]
}

resource "grafana_dashboard" "jmx_dashboards" {
  folder      = grafana_folder.jmx_dashboards.id
  config_json = file("files/dashboard.json")
}