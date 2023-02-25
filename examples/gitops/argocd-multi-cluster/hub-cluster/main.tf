provider "aws" {
  region  = local.region
  profile = local.hub_profile
}

provider "bcrypt" {
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region, "--profile", local.hub_profile]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region, "--profile", local.hub_profile]
      command     = "aws"
    }
  }
}

# To get the hosted zone to be use in argocd domain
data "aws_route53_zone" "argocd" {
  count        = local.argocd_domain == "" ? 0 : 1
  name         = local.argocd_domain
  private_zone = local.argocd_domain_private_zone
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_iam_policy_document" "irsa_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = ["sts:AssumeRole"]
  }
}

locals {
  name             = "hub-cluster"
  hub_cluster_name = var.hub_cluster_name

  cluster_version = "1.24"

  instance_type = "m5.large"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

  namespace = "argocd"

  argocd_domain              = var.argocd_domain
  argocd_domain_arn          = data.aws_route53_zone.argocd[0].arn
  argocd_domain_private_zone = var.argocd_domain_private_zone

  # Multi-{account,region} setup
  region      = var.hub_region
  hub_profile = var.hub_profile

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

  eks_managed_node_groups = {
    initial = {
      instance_types = [local.instance_type]

      min_size     = 1
      max_size     = 4
      desired_size = 2
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# EKS Blueprints Add-Ons
#---------------------------------------------------------------
module "eks_blueprints_kubernetes_addons" {
  source = "../../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_oidc_provider    = module.eks.oidc_provider
  eks_cluster_version  = module.eks.cluster_version

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates addons to be install via ArgoCD
  argocd_helm_config = {
    namespace = local.namespace
    version   = "5.23.1" # ArgoCD v2.6.2
    values = [
      yamlencode(
        {
          dex : {
            enabled : false # Disable dex since we are not using
          }
          redis-ha : {
            enabled : true
          }
          controller : {
            replicas : 3 # Additional replicas will cause sharding of managed clusters across number of replicas.
            serviceAccount : {
              annotations : {
                "eks.amazonaws.com/role-arn" : module.argocd_irsa.irsa_iam_role_arn
              }
            }
          }
          repoServer : {
            autoscaling : {
              enabled : true
              minReplicas : 2
            }
          }
          applicationSet : {
            replicaCount : 2
          }
          server : {
            autoscaling : {
              enabled : true
              minReplicas : 2
            }
            serviceAccount : {
              annotations : {
                "eks.amazonaws.com/role-arn" : module.argocd_irsa.irsa_iam_role_arn
              }
            }
            #service : {
            #  type : "LoadBalancer"  # To use LoadBalaner uncomment here, and comment out below ingress and ingressGrpc
            #}
            ingress : {
              enabled : true
              annotations : {
                "alb.ingress.kubernetes.io/scheme" : "internet-facing"
                "alb.ingress.kubernetes.io/target-type" : "ip"
                "alb.ingress.kubernetes.io/backend-protocol" : "HTTPS"
                "alb.ingress.kubernetes.io/listen-ports" : "[{\"HTTPS\":443}]"
                "alb.ingress.kubernetes.io/tags" : "Environment=hub,GitOps=true"
              }
              hosts : ["argocd.${local.argocd_domain}"]
              tls : [
                {
                  hosts : ["argocd.${local.argocd_domain}"]
                }
              ]
              ingressClassName : "alb"
            }
            ingressGrpc : {
              enabled : true
              isAWSALB : true
              awsALB : {
                serviceType : "ClusterIP"       # Instance mode needs type NodePort, IP mode needs type ClusterIP or NodePort
                backendProtocolVersion : "GRPC" ## This tells AWS to send traffic from the ALB using HTTP2. Can use gRPC as well if you want to leverage gRPC specific features
              }
            }
          }
          configs : {
            params : {
              "application.namespaces" : "cluster-*" # See more config options at https://argo-cd.readthedocs.io/en/stable/operator-manual/app-any-namespace/
            }
          }
        }
      )
    ]
    set_sensitive = [
      {
        name  = "configs.secret.argocdServerAdminPassword"
        value = bcrypt_hash.argo.id
      }
    ]
  }

  argocd_applications = {
    addons = {
      add_on_application = true
      path               = "chart"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-add-ons.git"
      target_revision    = "argo-multi-cluster"
      #repo_url             = "git@github.com:csantanapr-test-gitops-1/eks-blueprints-add-ons.git" #TODO change to https://github.com/aws-samples/eks-blueprints-add-ons once git repo is updated
      #ssh_key_secret_name  = "github-ssh-key" # Needed for private repos
      #git_secret_namespace = "argocd"
      #git_secret_name      = "${local.name}-addons"
    }
    # This shows how to deploy an application to leverage cluster generator  https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Cluster/
    application-set = {
      add_on_application = false
      path               = "application-sets"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-workloads.git"
      target_revision    = "argo-multi-cluster"
      #repo_url             = "git@github.com:csantanapr-test-gitops-1/eks-blueprints-workloads.git" #TODO change to https://github.com/aws-samples/eks-blueprints-workloads once git repo is updated
      #ssh_key_secret_name  = "github-ssh-key"# Needed for private repos
      #git_secret_namespace = "argocd"
      #git_secret_name      = "${local.name}-workloads"
    }
  }


  # Add-ons
  enable_aws_load_balancer_controller = true                      # ArgoCD UI depends on aws-loadbalancer-controller for Ingress
  enable_metrics_server               = true                      # ArgoCD HPAs depend on metric-server
  enable_external_dns                 = true                      # ArgoCD Server and UI use valid https domain name
  external_dns_route53_zone_arns      = [local.argocd_domain_arn] # ArgoCD Server and UI domain name is registered in Route 53

  tags = local.tags
}

resource "random_password" "argocd" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# argo expects bcrypt
resource "bcrypt_hash" "argo" {
  cleartext = random_password.argocd.result
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "argocd" {
  name = "argocd-login-2"
  # Set to zero for this example to force delete during Terraform destroy
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "argocd" {
  secret_id     = aws_secretsmanager_secret.argocd.id
  secret_string = random_password.argocd.result
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

  # manage so we can name them
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

module "argocd_irsa" {
  source                            = "../../../../modules/irsa"
  kubernetes_namespace              = local.namespace
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_service_account        = "argocd-*"
  irsa_iam_role_name                = "argocd-hub"
  irsa_iam_policies                 = [aws_iam_policy.irsa_policy.arn]
  eks_cluster_id                    = module.eks.cluster_name
  eks_oidc_provider_arn             = module.eks.oidc_provider_arn
  tags                              = local.tags
}

resource "aws_iam_policy" "irsa_policy" {
  name        = "${module.eks.cluster_name}-argocd-irsa"
  description = "IAM Policy for ArgoCD Hub"
  policy      = data.aws_iam_policy_document.irsa_policy.json
  tags        = local.tags
}
