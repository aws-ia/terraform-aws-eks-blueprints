provider "aws" {
  region  = local.region
  profile = local.spoke_profile
}

# Modify based in which account the hub cluster is located
provider "aws" {
  region  = local.hub_region
  profile = local.hub_profile
  alias   = "hub"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region, "--profile", local.spoke_profile]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region, "--profile", local.spoke_profile]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region, "--profile", local.spoke_profile]
    command     = "aws"
  }
  load_config_file  = false
  apply_retry_count = 15
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.hub.endpoint
  cluster_ca_certificate = try(base64decode(data.aws_eks_cluster.hub.certificate_authority[0].data), "")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.hub_cluster_name, "--region", local.region, "--profile", local.hub_profile]
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
      args        = ["eks", "get-token", "--cluster-name", local.hub_cluster_name, "--region", local.region, "--profile", local.hub_profile]
      command     = "aws"
    }
  }
  alias = "hub"
}

data "aws_eks_cluster" "hub" {
  provider = aws.hub
  name     = local.hub_cluster_name
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_iam_role" "argo_role" {
  provider = aws.hub
  name     = "${local.hub_cluster_name}-argocd-hub"
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

resource "aws_iam_role" "spoke_role" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

locals {
  name             = var.spoke_cluster_name
  hub_cluster_name = var.hub_cluster_name
  environment      = var.environment


  cluster_version = "1.24"

  instance_type = "m5.large"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }

  # Multi-{account,region} setup
  region        = var.spoke_region
  spoke_profile = var.spoke_profile
  hub_region    = var.hub_region
  hub_profile   = var.hub_profile

}

################################################################################
# Cluster
################################################################################

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

      min_size     = 3
      max_size     = 10
      desired_size = 5
    }
  }

  tags = local.tags
}


################################################################################
# EKS Blueprints Add-Ons IRSA config
################################################################################

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints-addons?ref=argo-multi-cluster"

  eks_cluster_id       = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_oidc_provider    = module.eks.oidc_provider
  eks_cluster_version  = module.eks.cluster_version

  argocd_manage_add_ons = true # Indicates addons to be install via ArgoCD


  # EKS Add-ons (Some addons required custom configuration, review the specifc addon documentation and add any required configuration below)
  enable_amazon_eks_aws_ebs_csi_driver         = try(var.addons.enable_amazon_eks_aws_ebs_csi_driver, false)
  enable_aws_load_balancer_controller          = try(var.addons.enable_aws_load_balancer_controller, false)
  enable_metrics_server                        = try(var.addons.enable_metrics_server, false)
  enable_coredns_autoscaler                    = try(var.addons.enable_coredns_autoscaler, false)
  enable_appmesh_controller                    = try(var.addons.enable_appmesh_controller, false)
  enable_ondat                                 = try(var.addons.enable_ondat, false)
  enable_external_dns                          = try(var.addons.enable_external_dns, false)
  enable_amazon_prometheus                     = try(var.addons.enable_amazon_prometheus, false)
  enable_prometheus                            = try(var.addons.enable_prometheus, false)
  enable_kube_prometheus_stack                 = try(var.addons.enable_kube_prometheus_stack, false)
  enable_kube_state_metrics                    = try(var.addons.enable_kube_state_metrics, false)
  enable_sysdig_agent                          = try(var.addons.enable_sysdig_agent, false)
  enable_tetrate_istio                         = try(var.addons.enable_tetrate_istio, false)
  enable_thanos                                = try(var.addons.enable_thanos, false)
  enable_traefik                               = try(var.addons.enable_traefik, false)
  enable_agones                                = try(var.addons.enable_agones, false)
  enable_aws_efs_csi_driver                    = try(var.addons.enable_aws_efs_csi_driver, false)
  enable_aws_fsx_csi_driver                    = try(var.addons.enable_aws_fsx_csi_driver, false)
  enable_ingress_nginx                         = try(var.addons.enable_ingress_nginx, false)
  enable_spark_history_server                  = try(var.addons.enable_spark_history_server, false)
  enable_spark_k8s_operator                    = try(var.addons.enable_spark_k8s_operator, false)
  enable_aws_for_fluentbit                     = try(var.addons.enable_aws_for_fluentbit, false)
  enable_aws_cloudwatch_metrics                = try(var.addons.enable_aws_cloudwatch_metrics, false)
  enable_cert_manager_csi_driver               = try(var.addons.enable_cert_manager_csi_driver, false)
  enable_cert_manager_istio_csr                = try(var.addons.enable_cert_manager_istio_csr, false)
  enable_argo_workflows                        = try(var.addons.enable_argo_workflows, false)
  enable_argo_rollouts                         = try(var.addons.enable_argo_rollouts, false)
  enable_aws_node_termination_handler          = try(var.addons.enable_aws_node_termination_handler, false)
  enable_karpenter                             = try(var.addons.enable_karpenter, false)
  karpenter_enable_spot_termination_handling   = try(var.addons.karpenter_enable_spot_termination_handling, false)
  enable_keda                                  = try(var.addons.enable_keda, false)
  enable_kubernetes_dashboard                  = try(var.addons.enable_kubernetes_dashboard, false)
  enable_vault                                 = try(var.addons.enable_vault, false)
  enable_vpa                                   = try(var.addons.enable_vpa, false)
  enable_yunikorn                              = try(var.addons.enable_yunikorn, false)
  enable_aws_privateca_issuer                  = try(var.addons.enable_aws_privateca_issuer, false)
  enable_opentelemetry_operator                = try(var.addons.enable_opentelemetry_operator, false)
  enable_amazon_eks_adot                       = try(var.addons.enable_amazon_eks_adot, false)
  enable_velero                                = try(var.addons.enable_velero, false)
  enable_adot_collector_java                   = try(var.addons.enable_adot_collector_java, false)
  enable_adot_collector_haproxy                = try(var.addons.enable_adot_collector_haproxy, false)
  enable_adot_collector_memcached              = try(var.addons.enable_adot_collector_memcached, false)
  enable_adot_collector_nginx                  = try(var.addons.enable_adot_collector_nginx, false)
  enable_secrets_store_csi_driver_provider_aws = try(var.addons.enable_secrets_store_csi_driver_provider_aws, false)
  enable_secrets_store_csi_driver              = try(var.addons.enable_secrets_store_csi_driver, false)
  enable_external_secrets                      = try(var.addons.enable_external_secrets, false)
  enable_grafana                               = try(var.addons.enable_grafana, false)
  enable_kuberay_operator                      = try(var.addons.enable_kuberay_operator, false)
  enable_reloader                              = try(var.addons.enable_reloader, false)
  enable_strimzi_kafka_operator                = try(var.addons.enable_strimzi_kafka_operator, false)
  enable_datadog_operator                      = try(var.addons.enable_datadog_operator, false)
  enable_airflow                               = try(var.addons.enable_airflow, false)
  enable_promtail                              = try(var.addons.enable_promtail, false)
  enable_calico                                = try(var.addons.enable_calico, false)
  enable_kubecost                              = try(var.addons.enable_kubecost, false)
  enable_kyverno                               = try(var.addons.enable_kyverno, false)
  enable_kyverno_policies                      = try(var.addons.enable_kyverno_policies, false)
  enable_kyverno_policy_reporter               = try(var.addons.enable_kyverno_policy_reporter, false)
  enable_smb_csi_driver                        = try(var.addons.enable_smb_csi_driver, false)
  enable_chaos_mesh                            = try(var.addons.enable_chaos_mesh, false)
  enable_cilium                                = try(var.addons.enable_cilium, false)
  cilium_enable_wireguard                      = try(var.addons.cilium_enable_wireguard, false)
  enable_gatekeeper                            = try(var.addons.enable_gatekeeper, false)
  enable_portworx                              = try(var.addons.enable_portworx, false)
  enable_local_volume_provisioner              = try(var.addons.enable_local_volume_provisioner, false)
  enable_nvidia_device_plugin                  = try(var.addons.enable_nvidia_device_plugin, false)
  enable_app_2048                              = try(var.addons.enable_app_2048, false)
  enable_emr_on_eks                            = try(var.addons.enable_emr_on_eks, false)
  enable_consul                                = try(var.addons.enable_consul, false)
  enable_cluster_autoscaler                    = try(var.addons.enable_cluster_autoscaler, false)
  cluster_autoscaler_helm_config = {
    set = [
      {
        name  = "podLabels.prometheus\\.io/scrape",
        value = "true",
        type  = "string",
      }
    ]
  }
  enable_cert_manager = try(var.addons.enable_cert_manager, false)
  cert_manager_helm_config = {
    set_values = [
      {
        name  = "extraArgs[0]"
        value = "--enable-certificate-owner-ref=false"
      },
    ]
  }
  enable_crossplane = try(var.addons.enable_crossplane, false)
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
# Create Namespace and ArgoCD Project for Spoke Cluster "cluster-*"
################################################################################

resource "helm_release" "argocd_project" {
  provider         = helm.hub
  name             = "argo-project-${local.name}"
  chart            = "${path.module}/argo-project"
  namespace        = "argocd"
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

################################################################################
# EKS Blueprints Add-Ons via ArgoCD
################################################################################

module "eks_blueprints_argocd_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints-addons//modules/argocd?ref=argo-multi-cluster"
  providers = {
    helm       = helm.hub
    kubernetes = kubernetes.hub
  }

  argocd_skip_install = true # Indicates this is a remote cluster for ArgoCD

  helm_config = {
    namespace = local.name # Use cluster name as namespace for ArgoCD Apps
  }

  applications = {
    # This shows how to deploy Cluster addons using ArgoCD App of Apps pattern
    "${local.environment}-addons" = {
      add_on_application = true
      path               = "chart"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-add-ons.git" #TODO change to https://github.com/aws-samples/eks-blueprints-add-ons once git repo is updated
      #repo_url             = "git@github.com:csantanapr-test-gitops-1/eks-blueprints-add-ons.git" #TODO change to https://github.com/aws-samples/eks-blueprints-add-ons once git repo is updated
      #ssh_key_secret_name  = "github-ssh-key" # Needed for private repos
      #git_secret_namespace = "argocd"
      #git_secret_name      = "${local.name}-addons"
      target_revision = "argo-multi-cluster" #TODO change to main once git repo is updated
      project         = local.name
      values = {
        destinationServer = module.eks.cluster_endpoint # Indicates the location of the remote cluster to deploy Addons
        argoNamespace     = local.name                  # Namespace to create ArgoCD Apps
        argoProject       = local.name                  # Argo Project
        targetRevision    = "argo-multi-cluster"        #TODO change to main once git repo is updated
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

################################################################################
# EKS Workloads via ArgoCD
################################################################################

module "eks_blueprints_argocd_workloads" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints-addons//modules/argocd?ref=argo-multi-cluster"
  providers = {
    helm       = helm.hub
    kubernetes = kubernetes.hub
  }

  argocd_skip_install = true # Indicates this is a remote cluster for ArgoCD
  helm_config = {
    namespace = local.name # Use cluster name as namespace for ArgoCD Apps
  }

  applications = {
    # This shows how to deploy a multiple workloads using ArgoCD App of Apps pattern
    "${local.environment}-workloads" = {
      add_on_application = false
      path               = "envs/${local.environment}"
      repo_url           = "https://github.com/csantanapr/eks-blueprints-workloads.git" #TODO change to https://github.com/aws-samples/eks-blueprints-workloads once git repo is updated
      #repo_url             = "git@github.com:csantanapr-test-gitops-1/eks-blueprints-workloads.git" #TODO change to https://github.com/aws-samples/eks-blueprints-workloads once git repo is updated
      #ssh_key_secret_name  = "github-ssh-key"# Needed for private repos
      #git_secret_namespace = "argocd"
      #git_secret_name      = "${local.name}-workloads"
      target_revision = "argo-multi-cluster" #TODO change to main once git repo is updated
      project         = local.name
      values = {
        destinationServer = "https://kubernetes.default.svc" # Indicates the location where ArgoCD is installed, in this case hub cluster
        argoNamespace     = local.name                       # Namespace to create ArgoCD Apps
        argoProject       = local.name                       # Argo Project
        spec = {
          destination = {
            server = module.eks.cluster_endpoint # Indicates the location of the remote cluster to deploy Apps
          }
          source = {
            repoURL = "https://github.com/csantanapr/eks-blueprints-workloads.git" #TODO change to https://github.com/aws-samples/eks-blueprints-workloads once git repo is updated
            #repoURL        = "git@github.com:csantanapr-test-gitops-1/eks-blueprints-workloads.git" #TODO change to https://github.com/aws-samples/eks-blueprints-workloads once git repo is updated
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
      destination        = module.eks.cluster_endpoint
      namespace          = "single-workload"
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
      "environment" : local.environment
    }
    annotations = {
      "project" : local.name
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
