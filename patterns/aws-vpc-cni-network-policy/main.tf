provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  name   = basename(path.cwd)
  region = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name                   = local.name
  cluster_version                = "1.27" # Must be 1.25 or higher
  cluster_endpoint_public_access = true
  cluster_ip_family              = "ipv4" # Must be ipv4 or ipv6

  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }

      configuration_values = jsonencode({
        enableNetworkPolicy : "true",
      })
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      min_size     = 3
      max_size     = 10
      desired_size = 5
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

################################################################################
# Demo application
################################################################################

resource "helm_release" "management_ui" {
  name             = "management-ui"
  chart            = "./demo-application/charts/management-ui"
  namespace        = "management-ui"
  create_namespace = true

  depends_on = [module.eks]
}

resource "helm_release" "backend" {
  name             = "backend"
  chart            = "./demo-application/charts/backend"
  namespace        = "stars"
  create_namespace = true

  depends_on = [module.eks]
}

resource "helm_release" "frontend" {
  name             = "backend"
  chart            = "./demo-application/charts/frontend"
  namespace        = "stars"
  create_namespace = true

  depends_on = [module.eks]
}

resource "helm_release" "client" {
  name             = "backend"
  chart            = "./demo-application/charts/client"
  namespace        = "client"
  create_namespace = true

  depends_on = [module.eks]
}

################################################################################
# Restrict access using K8S Network Policies
################################################################################

resource "kubectl_manifest" "default_deny_stars" {
  yaml_body  = <<YAML
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: default-deny
  namespace: stars
spec:
  podSelector:
    matchLabels: {}
YAML
  depends_on = [helm_release.management_ui, helm_release.frontend, helm_release.backend, helm_release.client]
}

# Block all ingress and egress traffic within the client ns
resource "kubectl_manifest" "default_deny_client" {
  yaml_body  = <<YAML
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: default-deny
  namespace: client
spec:
  podSelector:
    matchLabels: {}
YAML
  depends_on = [helm_release.management_ui, helm_release.frontend, helm_release.backend, helm_release.client]
}

# Allow the management-ui to access the star application
resource "kubectl_manifest" "allow_traffic_from_management_ui_to_application_components" {
  yaml_body  = <<YAML
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: stars
  name: allow-ui 
spec:
  podSelector:
    matchLabels: {}
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              role: management-ui 
YAML
  depends_on = [helm_release.management_ui, helm_release.frontend, helm_release.backend, helm_release.client]
}

# Allow the management-ui to access the client application
resource "kubectl_manifest" "allow_traffic_from_management_ui_to_client" {
  yaml_body  = <<YAML
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: client 
  name: allow-ui 
spec:
  podSelector:
    matchLabels: {}
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              role: management-ui 
YAML
  depends_on = [helm_release.management_ui, helm_release.frontend, helm_release.backend, helm_release.client]
}

# Allow the frontend to access the backend
resource "kubectl_manifest" "allow_traffic_from_frontend_to_backend" {
  yaml_body  = <<YAML
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: stars
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      role: backend
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 6379

YAML
  depends_on = [helm_release.management_ui, helm_release.frontend, helm_release.backend, helm_release.client]
}

# Allow the client to access the frontend
resource "kubectl_manifest" "allow_traffic_from_client_to_frontend" {
  yaml_body  = <<YAML
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: stars
  name: frontend-policy
spec:
  podSelector:
    matchLabels:
      role: frontend 
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              role: client
      ports:
        - protocol: TCP
          port: 80
YAML
  depends_on = [helm_release.management_ui, helm_release.frontend, helm_release.backend, helm_release.client]
}