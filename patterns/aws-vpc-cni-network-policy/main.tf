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
  version = "~> 20.0"

  cluster_name                   = local.name
  cluster_version                = "1.29" # Must be 1.25 or higher
  cluster_endpoint_public_access = true

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
# EKS Addons (demo application)
################################################################################

module "addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # EKS Addons
  eks_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      most_recent = true # Must be 1.14.0 or higher

      timeouts = {
        create = "25m"
        delete = "10m"
      }

      # Must enable network policy support
      configuration_values = jsonencode({
        enableNetworkPolicy : "true",
      })
    }
  }

  # Deploy demo-application
  helm_releases = {
    demo-application = {
      description = "A Helm chart to deploy the network policy demo application"
      namespace   = "default"
      chart       = "./charts/demo-application"
    }
  }

  tags = local.tags
}

################################################################################
# Restrict traffic flow using Network Policies
################################################################################

# Block all ingress and egress traffic within the stars namespace
resource "kubernetes_network_policy_v1" "default_deny_stars" {
  metadata {
    name      = "default-deny"
    namespace = "stars"
  }
  spec {
    policy_types = ["Ingress"]
    pod_selector {
      match_labels = {}
    }
  }
  depends_on = [module.addons]
}

# Block all ingress and egress traffic within the client namespace
resource "kubernetes_network_policy_v1" "default_deny_client" {
  metadata {
    name      = "default-deny"
    namespace = "client"
  }
  spec {
    policy_types = ["Ingress"]
    pod_selector {
      match_labels = {}
    }
  }
  depends_on = [module.addons]
}

# Allow the management-ui to access the star application pods
resource "kubernetes_network_policy_v1" "allow_ui_to_stars" {
  metadata {
    name      = "allow-ui"
    namespace = "stars"
  }
  spec {
    policy_types = ["Ingress"]
    pod_selector {
      match_labels = {}
    }
    ingress {
      from {
        namespace_selector {
          match_labels = {
            role = "management-ui"
          }
        }
      }
    }
  }
  depends_on = [module.addons]
}

# Allow the management-ui to access the client application pods
resource "kubernetes_network_policy_v1" "allow_ui_to_client" {
  metadata {
    name      = "allow-ui"
    namespace = "client"
  }
  spec {
    policy_types = ["Ingress"]
    pod_selector {
      match_labels = {}
    }
    ingress {
      from {
        namespace_selector {
          match_labels = {
            role = "management-ui"
          }
        }
      }
    }
  }
  depends_on = [module.addons]
}

# Allow the frontend pod to access the backend pod within the stars namespace
resource "kubernetes_network_policy_v1" "allow_frontend_to_backend" {
  metadata {
    name      = "backend-policy"
    namespace = "stars"
  }
  spec {
    policy_types = ["Ingress"]
    pod_selector {
      match_labels = {
        role = "backend"
      }
    }
    ingress {
      from {
        pod_selector {
          match_labels = {
            role = "frontend"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = "6379"
      }
    }
  }
  depends_on = [module.addons]
}

# Allow the client pod to access the frontend pod within the stars namespace
resource "kubernetes_network_policy_v1" "allow_client_to_backend" {
  metadata {
    name      = "frontend-policy"
    namespace = "stars"
  }

  spec {
    policy_types = ["Ingress"]
    pod_selector {
      match_labels = {
        role = "frontend"
      }
    }
    ingress {
      from {
        namespace_selector {
          match_labels = {
            role = "client"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = "80"
      }
    }
  }
  depends_on = [module.addons]
}
