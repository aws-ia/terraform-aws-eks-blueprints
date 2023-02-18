provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.hub.endpoint
  cluster_ca_certificate = try(base64decode(data.aws_eks_cluster.hub.certificate_authority[0].data), "")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.hub_cluster_name, "--region", local.region]
    command     = "aws"
  }
  alias = "hub"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.hub.endpoint
    cluster_ca_certificate = try(base64decode(data.aws_eks_cluster.hub.certificate_authority[0].data), "")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.hub_cluster_name, "--region", local.region]
      command     = "aws"
    }
  }
  alias = "hub"
}

data "aws_eks_cluster" "hub" {
  name = local.hub_cluster_name
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_iam_role" "argo_role" {
  name = "argocd-hub"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.argo_role.arn]
    }
  }
}

locals {
  name             = var.spoke_cluster_name
  hub_cluster_name = var.hub_cluster_name
  region           = "us-west-2"

  cluster_version = "1.24"

  instance_type = "t3a.xlarge" #TODO change to m5.large before merging PR

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# EKS Cluster
#---------------------------------------------------------------
#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.7"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  # Granting access to hub cluster
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.spoke_role.arn
      username = "gitops-role"
      groups   = ["system:masters"]
    }
  ]

  eks_managed_node_groups = {
    initial = {
      instance_types = [local.instance_type]

      min_size     = 1
      max_size     = 4
      desired_size = 3
    }
  }

  tags = local.tags
}


#---------------------------------------------------------------
# EKS Blueprints Add-Ons IRSA config
#---------------------------------------------------------------
module "eks_blueprints_kubernetes_addons" {
  source = "../../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_oidc_provider    = module.eks.oidc_provider
  eks_cluster_version  = module.eks.cluster_version

  argocd_manage_add_ons = true # Indicates addons to be install via ArgoCD


  enable_ingress_nginx                = false
  enable_aws_load_balancer_controller = true
  enable_datadog_operator             = false
  enable_metrics_server               = true

  tags = local.tags
}




#---------------------------------------------------------------
# Create Namespace and ArgoCD Project
#---------------------------------------------------------------
resource "helm_release" "argocd_project" {
  provider = helm.hub
  name       = "argo-project"
  chart      = "${path.module}/argo-project"
  namespace  = "argocd"
  create_namespace = true
  values = [
      yamlencode(
        {
          name = local.name
          spec : {
            sourceNamespaces : [
                local.name
            ]
          }
        }
      )
    ]
  depends_on = [module.eks_blueprints_kubernetes_addons]
}

#---------------------------------------------------------------
# EKS Blueprints Add-Ons via ArgoCD
#---------------------------------------------------------------
module "eks_blueprints_argocd_addons" {
  source = "../../../../modules/kubernetes-addons/argocd"
  providers = {
    helm       = helm.hub
    kubernetes = kubernetes.hub
  }

  argocd_remote = true # Indicates this is a remote cluster for ArgoCD

  helm_config = {
    namespace = local.name # Use cluster name as namespace for ArgoCD Apps
  }

  applications = {
    # This shows how to deploy Cluster addons using ArgoCD App of Apps pattern
    addons = {
      add_on_application = true
      path               = "chart"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-add-ons.git"  #TODO change to https://github.com/aws-samples/eks-blueprints-add-ons once git repo is updated
      target_revision    = "argo-multi-cluster" #TODO change to main once git repo is updated
      project            = local.name
      values = {
        destinationServer = module.eks.cluster_endpoint # Indicates the location of the remote cluster to deploy Addons
        argoNamespace     = local.name # Namespace to create ArgoCD Apps
        argoProject       = local.name # Argo Project
        targetRevision    = "argo-multi-cluster" #TODO change to main once git repo is updated
      }
    }
  }

  addon_config = { for k, v in module.eks_blueprints_kubernetes_addons.argocd_addon_config : k => v if v != null }

  addon_context = {
    aws_region_name                = local.region
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    eks_cluster_id                 = module.eks.cluster_name
  }

  depends_on = [helm_release.argocd_project]
}





#---------------------------------------------------------------
# EKS Workloads via ArgoCD
#---------------------------------------------------------------
module "eks_blueprints_argocd_workloads" {
  source = "../../../../modules/kubernetes-addons/argocd"
  providers = {
    helm       = helm.hub
    kubernetes = kubernetes.hub
  }

  argocd_remote = true # Indicates this is a remote cluster for ArgoCD
  helm_config = {
    namespace = local.name # Use cluster name as namespace for ArgoCD Apps
  }

  applications = {
    # This shows how to deploy a multiple workloads using ArgoCD App of Apps pattern
    workloads = {
      add_on_application = false
      path               = "envs/dev"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-workloads.git" #TODO change to https://github.com/aws-samples/eks-blueprints-workloads once git repo is updated
      target_revision    = "argo-multi-cluster" #TODO change to main once git repo is updated
      project            = local.name
      values = {
        destinationServer = "https://kubernetes.default.svc" # Indicates the location where ArgoCD is installed, in this case hub cluster
        argoNamespace     = local.name # Namespace to create ArgoCD Apps
        argoProject       = local.name # Argo Project
        spec = {
          destination = {
            server = module.eks.cluster_endpoint # Indicates the location of the remote cluster to deploy Apps
          }
          source = {
            repoURL = "https://github.com/csantanapr/eks-blueprints-workloads.git" #TODO change to https://github.com/aws-samples/eks-blueprints-workloads once git repo is updated
            targetRevision = "argo-multi-cluster" #TODO change to main once git repo is updated
          }
          ingress = {
            argocd = false
          }
        }
      }
    } 
    # This shows how to deploy a workload using a single ArgoCD App
    "single-workload" = {
      add_on_application = false
      path               = "helm-guestbook"
      repo_url           = "https://github.com/argoproj/argocd-example-apps.git"
      target_revision    = "master"
      project            = local.name
      destination = module.eks.cluster_endpoint
      namespace = "single-workload"
    } 
  }

  addon_context = {
    aws_region_name                = local.region
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    eks_cluster_id                 = module.eks.cluster_name
  }

  depends_on = [module.eks_blueprints_argocd_addons]

}


# Secret in hub
resource "kubernetes_secret_v1" "spoke_cluster" {
  provider = kubernetes.hub
  metadata {
    name      = local.name
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" : "cluster"
    }
  }
  data = {
    server = module.eks.cluster_endpoint
    name   = local.name
    config = jsonencode(
      {
        execProviderConfig : {
          apiVersion : "client.authentication.k8s.io/v1beta1",
          command : "argocd-k8s-auth",
          args : [
            "aws",
            "--cluster-name",
            local.name,
            "--role-arn",
            aws_iam_role.spoke_role.arn
          ],
          env : {
            AWS_REGION : local.region
          }
        },
        tlsClientConfig : {
          insecure : false,
          caData : module.eks.cluster_certificate_authority_data
        }
      }
    )
  }
}


#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------'
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
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

resource "aws_iam_role" "spoke_role" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
