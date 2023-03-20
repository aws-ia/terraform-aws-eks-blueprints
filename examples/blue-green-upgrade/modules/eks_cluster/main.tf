locals {
  core_stack_name   = var.core_stack_name
  suffix_stack_name = var.suffix_stack_name

  env  = "dev" # use to suffix some kubernetes objects
  name = "${var.core_stack_name}-${local.suffix_stack_name}"

  eks_cluster_domain = "${local.core_stack_name}.${var.hosted_zone_name}" # for external-dns

  cluster_version = var.cluster_version

  # Route 53 Ingress Weights
  argocd_route53_weight      = var.argocd_route53_weight
  route53_weight             = var.route53_weight
  ecsfrontend_route53_weight = var.ecsfrontend_route53_weight

  tag_val_vpc            = var.vpc_tag_value == "" ? var.core_stack_name : var.vpc_tag_value
  tag_val_private_subnet = var.vpc_tag_value == "" ? "${var.core_stack_name}-private-" : var.vpc_tag_value

  node_group_name            = "managed-ondemand"
  argocd_secret_manager_name = var.argocd_secret_manager_name_suffix

  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------

  addon_application = {
    path                = "chart"
    repo_url            = var.addons_repo_url
    ssh_key_secret_name = var.workload_repo_secret
    add_on_application  = true
  }

  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------

  workload_application = {
    path                = var.workload_repo_path # <-- we could also to blue/green on the workload repo path like: envs/dev-blue / envs/dev-green
    repo_url            = var.workload_repo_url
    target_revision     = var.workload_repo_revision
    ssh_key_secret_name = var.workload_repo_secret
    add_on_application  = false
    values = {
      labels = {
        env   = local.env
        myapp = "myvalue"
      }
      spec = {
        source = {
          repoURL        = var.workload_repo_url
          targetRevision = var.workload_repo_revision
        }
        blueprint                = "terraform"
        clusterName              = local.name
        karpenterInstanceProfile = "${local.name}-${local.node_group_name}"
        env                      = local.env
        ingress = {
          type                  = "alb"
          host                  = local.eks_cluster_domain
          route53_weight        = local.route53_weight # <-- You can control the weight of the route53 weighted records between clusters
          argocd_route53_weight = local.argocd_route53_weight
        }
      }
    }
  }

  #---------------------------------------------------------------
  # ARGOCD ECSDEMO APPLICATION
  #---------------------------------------------------------------

  ecsdemo_application = {
    path                = "multi-repo/argo-app-of-apps/dev"
    repo_url            = var.workload_repo_url
    target_revision     = var.workload_repo_revision
    ssh_key_secret_name = var.workload_repo_secret
    add_on_application  = false
    values = {
      spec = {
        blueprint                = "terraform"
        clusterName              = local.name
        karpenterInstanceProfile = "${local.name}-${local.node_group_name}"

        apps = {
          ecsdemoFrontend = {
            repoURL        = "https://github.com/aws-containers/ecsdemo-frontend"
            targetRevision = "main"
            replicaCount   = "3"
            image = {
              repository = "public.ecr.aws/seb-demo/ecsdemo-frontend"
              tag        = "latest"
            }
            ingress = {
              enabled   = "true"
              className = "alb"
              annotations = {
                "alb.ingress.kubernetes.io/scheme"                = "internet-facing"
                "alb.ingress.kubernetes.io/group.name"            = "ecsdemo"
                "alb.ingress.kubernetes.io/listen-ports"          = "[{\\\"HTTPS\\\": 443}]"
                "alb.ingress.kubernetes.io/ssl-redirect"          = "443"
                "alb.ingress.kubernetes.io/target-type"           = "ip"
                "external-dns.alpha.kubernetes.io/set-identifier" = local.name
                "external-dns.alpha.kubernetes.io/aws-weight"     = local.ecsfrontend_route53_weight
              }
              hosts = [
                {
                  host = "frontend.${local.eks_cluster_domain}"
                  paths = [
                    {
                      path     = "/"
                      pathType = "Prefix"
                    }
                  ]
                }
              ]
            }
            resources = {
              requests = {
                cpu    = "1"
                memory = "256Mi"
              }
              limits = {
                cpu    = "1"
                memory = "512Mi"
              }
            }
            autoscaling = {
              enabled                        = "true"
              minReplicas                    = "3"
              maxReplicas                    = "100"
              targetCPUUtilizationPercentage = "60"
            }
            nodeSelector = {
              "karpenter.sh/provisioner-name" = "burnham"
            }
            tolerations = [
              {
                key      = "burnham"
                operator = "Exists"
                effect   = "NoSchedule"
              }
            ]
            topologySpreadConstraints = [
              {
                maxSkew           = 1
                topologyKey       = "topology.kubernetes.io/zone"
                whenUnsatisfiable = "DoNotSchedule"
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name" = "ecsdemo-frontend"
                  }
                }
              }
            ]
          }
        }
      }
    }
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}


data "aws_partition" "current" {}

# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:${var.vpc_tag_key}"
    values = [local.tag_val_vpc]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:${var.vpc_tag_key}"
    values = ["${local.tag_val_private_subnet}*"]
  }
}

# Create Sub HostedZone four our deployment
data "aws_route53_zone" "sub" {
  name = "${var.core_stack_name}.${var.hosted_zone_name}"
}


data "aws_secretsmanager_secret" "argocd" {
  name = "${local.argocd_secret_manager_name}.${local.core_stack_name}"
}

data "aws_secretsmanager_secret_version" "admin_password_version" {
  secret_id = data.aws_secretsmanager_secret.argocd.id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.10"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = data.aws_vpc.vpc.id
  subnet_ids = data.aws_subnets.private.ids

  eks_managed_node_groups = {
    mg_5 = {
      node_group_name = local.node_group_name
      instance_types  = ["m5.xlarge"]
      min_size        = 3
      subnet_ids      = data.aws_subnets.private.ids
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_admin_role_name}" # The ARN of the IAM role
      username = "ops-role"                                                                                    # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"]                                                                            # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ]

  tags = local.tags
}

module "admin_team" {
  # Users should pin the version to the latest available release
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/aws-ia/terraform-aws-eks-blueprints-teams"

  name = "admin"

  # Enables elevated, admin privileges for this team
  enable_admin = true

  users = [
    data.aws_caller_identity.current.arn,
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${var.iam_platform_user}",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_admin_role_name}"
  ]

  cluster_arn = module.eks.cluster_arn

  tags = local.tags
}


module "application_teams" {
  # Users should pin the version to the latest available release
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/aws-ia/terraform-aws-eks-blueprints-teams"

  name              = "application_teams"
  users             = [data.aws_caller_identity.current.arn]
  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  namespaces = {
    team-burnham = {
      labels = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "burnham-team-app",
        "projectName"                             = "project-burnham",
        "environment"                             = "dev",
        "domain"                                  = "example",
        "uuid"                                    = "example",
        "billingCode"                             = "example",
        "branch"                                  = "example"
      }

      resource_quotas = {
        "requests.cpu"    = "10000m",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "20000m",
        "limits.memory"   = "50Gi",
        "pods"            = "10",
        "secrets"         = "10",
        "services"        = "10"
      }

      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "../kubernetes/team-burnham/"
    }

    team-riker = {
      labels = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "riker-team-app",
        "projectName"                             = "project-riker",
        "environment"                             = "dev",
        "domain"                                  = "example",
        "uuid"                                    = "example",
        "billingCode"                             = "example",
        "branch"                                  = "example"
      }
      resource_quotas = {
        "requests.cpu"    = "10000m",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "20000m",
        "limits.memory"   = "50Gi",
        "pods"            = "10",
        "secrets"         = "10",
        "services"        = "10"
      }

      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "../kubernetes/team-riker/"
    }

    ecsdemo-frontend = {
      labels = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "ecsdemo-frontend-app",
        "projectName"                             = "ecsdemo-frontend",
        "environment"                             = "dev",
      }
      #don't use quotas here cause ecsdemo app does not have request/limits
      resource_quotas = {
        "requests.cpu"    = "100",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "200",
        "limits.memory"   = "50Gi",
        "pods"            = "100",
        "secrets"         = "10",
        "services"        = "20"
      }
      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "../kubernetes/ecsdemo-frontend/"
    }

    ecsdemo-nodejs = {
      labels = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "ecsdemo-nodejs-app",
        "projectName"                             = "ecsdemo-nodejs",
        "environment"                             = "dev",
      }

      #don't use quotas here cause ecsdemo app does not have request/limits
      resource_quotas = {
        "requests.cpu"    = "10000m",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "20000m",
        "limits.memory"   = "50Gi",
        "pods"            = "10",
        "secrets"         = "10",
        "services"        = "10"
      }

      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "../kubernetes/ecsdemo-nodejs"
    }
    ecsdemo-crystal = {
      labels = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "ecsdemo-crystal-app",
        "projectName"                             = "ecsdemo-crystal",
        "environment"                             = "dev",
      }

      #don't use quotas here cause ecsdemo app does not have request/limits
      resource_quotas = {
        "requests.cpu"    = "10000m",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "20000m",
        "limits.memory"   = "50Gi",
        "pods"            = "10",
        "secrets"         = "10",
        "services"        = "10"
      }

      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "../kubernetes/ecsdemo-crystal"
    }
  }

  tags = local.tags
}

#certificate_arn = aws_acm_certificate_validation.example.certificate_arn

module "kubernetes_addons" {
  # Users should pin the version to the latest available release
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/aws-ia/terraform-aws-eks-blueprints-addons"

  cluster_name            = module.eks.cluster_name
  cluster_endpoint        = module.eks.cluster_endpoint
  cluster_version         = module.eks.cluster_version
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks.oidc_provider_arn

  #---------------------------------------------------------------
  # ARGO CD ADD-ON
  #---------------------------------------------------------------

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying Add-ons.

  argocd_applications = {
    addons    = local.addon_application
    workloads = local.workload_application
    ecsdemo   = local.ecsdemo_application
  }

  # This example shows how to set default ArgoCD Admin Password using SecretsManager with Helm Chart set_sensitive values.
  argocd_helm_config = {
    set_sensitive = [
      {
        name  = "configs.secret.argocdServerAdminPassword"
        value = bcrypt(data.aws_secretsmanager_secret_version.admin_password_version.secret_string)
      }
    ]
    set = [
      {
        name  = "server.service.type"
        value = "LoadBalancer"
      }
    ]
  }

  #---------------------------------------------------------------
  # EKS AddOns
  #---------------------------------------------------------------
  eks_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
    coredns = {}
    vpc-cni = {
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
    kube-proxy = {}
  }

  #---------------------------------------------------------------
  # ADD-ONS - You can add additional addons here
  # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
  #---------------------------------------------------------------

  enable_metrics_server               = true
  enable_vpa                          = true
  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller_helm_config = {
    service_account = "aws-lb-sa"
  }
  enable_karpenter              = true
  enable_aws_for_fluentbit      = true
  enable_aws_cloudwatch_metrics = true

  #to view the result : terraform state show 'module.kubernetes_addons.module.external_dns[0].module.helm_addon.helm_release.addon[0]'
  enable_external_dns = true

  external_dns_helm_config = {
    txtOwnerId   = local.name
    zoneIdFilter = data.aws_route53_zone.sub.zone_id # Note: this uses GitOpsBridge
    policy       = "sync"
    logLevel     = "debug"
  }
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.14"

  role_name_prefix = "${module.eks.cluster_name}-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.14"

  role_name_prefix = "${module.eks.cluster_name}-vpc-cni-"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}
