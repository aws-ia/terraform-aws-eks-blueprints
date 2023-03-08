provider "aws" {
  region  = local.region
  profile = local.hub_profile
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

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region, "--profile", local.hub_profile]
    command     = "aws"
  }
  load_config_file  = false
  apply_retry_count = 15
}

provider "bcrypt" {}

# To get the hosted zone to be use in argocd domain
data "aws_route53_zone" "domain_name" {
  count        = var.enable_ingress ? 1 : 0
  name         = local.domain_name
  private_zone = var.domain_private_zone
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_iam_policy_document" "irsa_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["sts:AssumeRole"]
  }
}

locals {
  name             = "hub-cluster"
  hub_cluster_name = var.hub_cluster_name
  domain_name      = var.domain_name

  cluster_version = "1.24"

  instance_type = "m5.large"

  vpc_cidr  = "10.0.0.0/16"
  azs_count = 3
  azs       = slice(data.aws_availability_zones.available.names, 0, local.azs_count)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

  argocd_namespace           = "argocd"
  argocd_subdomain           = "argocd"
  argocd_domain_arn          = data.aws_route53_zone.domain_name[0].arn

  # Multi-{account,region} setup
  region      = var.hub_region
  hub_profile = var.hub_profile

  # AWS Cognito for ArgoCD SSO
  argocd_sso = var.argocd_enable_sso ? templatefile("${path.module}/cognito.yaml", {
    issuer       = var.argocd_sso_issuer
    clientID     = var.argocd_sso_client_id
    clientSecret = var.argocd_sso_client_secret
    logoutURL    = "${var.argocd_sso_logout_url}?client_id=${var.argocd_sso_client_id}&logout_uri=https://${local.argocd_subdomain}.${local.domain_name}/logout"
    cliClientID  = var.argocd_sso_cli_client_id
    url          = "https://${local.argocd_subdomain}.${local.domain_name}"
  }) : ""
}

################################################################################
# Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.10"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = [local.instance_type]

      min_size     = 3
      max_size     = 10
      desired_size = 5
    }
  }

  tags = local.tags
}

################################################################################
# Kubernetes Addons
################################################################################

module "eks_blueprints_kubernetes_addons" {
  source = "../../../../modules/kubernetes-addons"

  eks_cluster_id       = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_oidc_provider    = module.eks.oidc_provider
  eks_cluster_version  = module.eks.cluster_version

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates addons to be install via ArgoCD
  argocd_helm_config = {
    namespace = local.argocd_namespace
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
            metrics : {
              enabled : true
              service : {
                annotations : {
                  "prometheus.io/scrape" : true
                }
              }
            }
          }
          repoServer : {
            autoscaling : {
              enabled : true
              minReplicas : local.azs_count
            }
            resources : { # Adjust based on your specific use case (required for HPA)
              limits : {
                cpu : "200m"
                memory : "512Mi"
              }
              requests : {
                cpu : "100m"
                memory : "256Mi"
              }
            }
            metrics : {
              enabled : true
              service : {
                annotations : {
                  "prometheus.io/scrape" : true
                }
              }
            }
          }
          applicationSet : {
            replicaCount : 2 # The controller doesn't scale horizontally, is active-standby replicas
            metrics : {
              enabled : true
              service : {
                annotations : {
                  "prometheus.io/scrape" : true
                }
              }
            }
          }
          server : {
            autoscaling : {
              enabled : true
              minReplicas : local.azs_count
            }
            resources : { # Adjust based on your specific use case (required for HPA)
              limits : {
                cpu : "200m"
                memory : "512Mi"
              }
              requests : {
                cpu : "100m"
                memory : "256Mi"
              }
            }
            metrics : {
              enabled : true
              service : {
                annotations : {
                  "prometheus.io/scrape" : true
                }
              }
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
              hosts : ["${local.argocd_subdomain}.${local.domain_name}"]
              tls : [
                {
                  hosts : ["${local.argocd_subdomain}.${local.domain_name}"]
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
            cm : {
              "application.resourceTrackingMethod" : "annotation+label" #use annotation for tracking but keep labels for compatibility with other tools
            }
          }
        }
      ),
      local.argocd_sso
    ]
    set_sensitive = [
      {
        name  = "configs.secret.argocdServerAdminPassword"
        value = bcrypt_hash.argo.id
      }
    ]
  }

  # Add-ons
  enable_aws_load_balancer_controller = true                      # ArgoCD UI depends on aws-loadbalancer-controller for Ingress
  enable_metrics_server               = true                      # ArgoCD HPAs depend on metric-server
  enable_external_dns                 = true                      # ArgoCD Server and UI use valid https domain name
  external_dns_route53_zone_arns      = [data.aws_route53_zone.domain_name[0].arn] # ArgoCD Server and UI domain name is registered in Route 53

  # Observability for ArgoCD
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_prometheus                    = true
  enable_amazon_prometheus             = true

  enable_crossplane = false
  crossplane_helm_config = {
    version = "1.11.1" # Get the latest version from https://charts.crossplane.io/stable
  }
  crossplane_aws_provider = {
    enable               = true
    provider_config      = "aws-provider-config"
    provider_aws_version = "v0.37.1" # Get the latest version from https://marketplace.upbound.io/providers/crossplane-contrib/provider-aws
  }
  crossplane_upbound_aws_provider = {
    enable               = false
    provider_config      = "aws-provider-config"
    provider_aws_version = "v0.30.0" # Get the latest version from   https://marketplace.upbound.io/providers/upbound/provider-aws
  }
  crossplane_kubernetes_provider = {
    enable                      = true
    provider_kubernetes_version = "v0.7.0" # Get the latest version from  https://marketplace.upbound.io/providers/crossplane-contrib/provider-kubernetes
  }
  crossplane_helm_provider = {
    enable                = true
    provider_helm_version = "v0.14.0" # Get the latest version from https://marketplace.upbound.io/providers/crossplane-contrib/provider-helm
  }

  tags = local.tags
}

################################################################################
# EKS Blueprints Add-Ons via ArgoCD
################################################################################

module "eks_blueprints_argocd_addons" {
  source = "../../../../modules/kubernetes-addons/argocd"

  argocd_skip_install = true # Skip argocd controller install

  helm_config = {
    namespace        = local.argocd_namespace
    create_namespace = false
  }

  applications = {
    # This shows how to deploy Cluster addons using ArgoCD App of Apps pattern
    addons = {
      add_on_application = true
      path               = "chart"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-add-ons.git"
      target_revision    = "argo-multi-cluster" #TODO change main
      #repo_url             = "git@github.com:csantanapr-test-gitops-1/eks-blueprints-add-ons.git" #TODO change to https://github.com/aws-samples/eks-blueprints-add-ons once git repo is updated
      #ssh_key_secret_name  = "github-ssh-key" # Needed for private repos
      #git_secret_namespace = "argocd"
      #git_secret_name      = "${local.name}-addons"
    }
  }

  addon_config = { for k, v in module.eks_blueprints_kubernetes_addons.argocd_addon_config : k => v if v != null }

  addon_context = {
    aws_region_name                = local.region
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    eks_cluster_id                 = module.eks.cluster_name
  }

  depends_on = [module.eks_blueprints_kubernetes_addons]
}


################################################################################
# EKS Workloads via ArgoCD
################################################################################

module "eks_blueprints_argocd_workloads" {
  source = "../../../../modules/kubernetes-addons/argocd"

  argocd_skip_install = true # Skip argocd controller install

  helm_config = {
    namespace        = local.argocd_namespace
    create_namespace = false
  }

  applications = {
    # This shows how to deploy an application to leverage cluster generator  https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Cluster/
    application-set = {
      add_on_application = false
      path               = "application-sets"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-workloads.git"
      target_revision    = "argo-multi-cluster" #TODO change to main
      #repo_url             = "git@github.com:csantanapr-test-gitops-1/eks-blueprints-workloads.git" #TODO change to https://github.com/aws-samples/eks-blueprints-workloads once git repo is updated
      #ssh_key_secret_name  = "github-ssh-key"# Needed for private repos
      #git_secret_namespace = "argocd"
      #git_secret_name      = "${local.name}-workloads"
    }

  }

  addon_context = {
    aws_region_name                = local.region
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    eks_cluster_id                 = module.eks.cluster_name
  }

  depends_on = [module.eks_blueprints_argocd_addons]

}

################################################################################
# ArgoCD Admin Password credentials with Secrets Manager
# Login to AWS Secrets manager with the same role as Terraform to extract the ArgoCD admin password with the secret name as "argocd"
################################################################################

resource "random_password" "argocd" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Argo requires the password to be bcrypt, we use custom provider of bcrypt,
# as the default bcrypt function generates diff for each terraform plan
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

module "argocd_irsa" {
  source                            = "../../../../modules/irsa"
  kubernetes_namespace              = local.argocd_namespace
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


resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.52.1"
  namespace  = "grafana"
  create_namespace  = true


  values = [templatefile("${path.module}/grafana-argocd/values.yaml", {
      operating_system = "linux"
      region           = local.region
    })]

  depends_on = [module.eks_blueprints_kubernetes_addons]
}


################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

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


################################################################################
# ACM Certificate
################################################################################

resource "aws_acm_certificate" "cert" {
  count               = var.enable_ingress ? 1 : 0
  domain_name         = "*.${local.domain_name}"
  validation_method   = "DNS"
}

resource "aws_route53_record" "cert" {
  count           = var.enable_ingress ? 1 : 0
  zone_id         = data.aws_route53_zone.domain_name[0].zone_id
  name            = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_name
  type            = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_type
  records         = [tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_value]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "cert" {
  count                   = var.enable_ingress ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
}
