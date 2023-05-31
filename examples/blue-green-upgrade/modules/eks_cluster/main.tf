# Required for public ECR where Karpenter artifacts are hosted
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

locals {
  environment = var.environment_name
  service     = var.service_name

  env  = local.environment
  name = "${local.environment}-${local.service}"


  # Mapping
  hosted_zone_name           = var.hosted_zone_name
  addons_repo_url            = var.addons_repo_url
  workload_repo_secret       = var.workload_repo_secret
  cluster_version            = var.cluster_version
  argocd_secret_manager_name = var.argocd_secret_manager_name_suffix
  workload_repo_path         = var.workload_repo_path
  workload_repo_url          = var.workload_repo_url
  workload_repo_revision     = var.workload_repo_revision
  eks_admin_role_name        = var.eks_admin_role_name
  iam_platform_user          = var.iam_platform_user

  metrics_server               = true
  aws_load_balancer_controller = true
  karpenter                    = true
  aws_for_fluentbit            = true
  cert_manager                 = true
  cloudwatch_metrics           = true
  external_dns                 = true
  vpa                          = true
  kubecost                     = true
  argo_rollouts                = true

  # Route 53 Ingress Weights
  argocd_route53_weight      = var.argocd_route53_weight
  route53_weight             = var.route53_weight
  ecsfrontend_route53_weight = var.ecsfrontend_route53_weight

  eks_cluster_domain = "${local.environment}.${local.hosted_zone_name}" # for external-dns

  tag_val_vpc            = local.environment
  tag_val_public_subnet  = "${local.environment}-public-"
  tag_val_private_subnet = "${local.environment}-private-"

  node_group_name = "managed-ondemand"


  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------

  #At this time (with new v5 addon repository), the Addons need to be managed by Terrform and not ArgoCD
  addons_application = {
    path                = "chart"
    repo_url            = local.addons_repo_url
    ssh_key_secret_name = local.workload_repo_secret
    add_on_application  = true
  }

  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------

  workload_application = {
    path                = local.workload_repo_path # <-- we could also to blue/green on the workload repo path like: envs/dev-blue / envs/dev-green
    repo_url            = local.workload_repo_url
    target_revision     = local.workload_repo_revision
    ssh_key_secret_name = local.workload_repo_secret
    add_on_application  = false
    values = {
      labels = {
        env   = local.env
        myapp = "myvalue"
      }
      spec = {
        source = {
          repoURL        = local.workload_repo_url
          targetRevision = local.workload_repo_revision
        }
        blueprint                = "terraform"
        clusterName              = local.name
        karpenterInstanceProfile = module.karpenter.instance_profile_name
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
    repo_url            = local.workload_repo_url
    target_revision     = local.workload_repo_revision
    ssh_key_secret_name = local.workload_repo_secret
    add_on_application  = false
    values = {
      spec = {
        blueprint                = "terraform"
        clusterName              = local.name
        karpenterInstanceProfile = module.karpenter.instance_profile_name

        apps = {
          ecsdemoNodejs = {
            replicaCount = "9"
            nodeSelector = {
              "karpenter.sh/provisioner-name" = "default"
            }
            tolerations = [
              {
                key      = "karpenter"
                operator = "Exists"
                effect   = "NoSchedule"
              }
            ]
            topologyAwareHints = "true"
            topologySpreadConstraints = [
              {
                maxSkew           = 1
                topologyKey       = "topology.kubernetes.io/zone"
                whenUnsatisfiable = "DoNotSchedule"
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name" = "ecsdemo-nodejs"
                  }
                }
              }
            ]
          }

          ecsdemoCrystal = {
            replicaCount = "9"
            nodeSelector = {
              "karpenter.sh/provisioner-name" = "default"
            }
            tolerations = [
              {
                key      = "karpenter"
                operator = "Exists"
                effect   = "NoSchedule"
              }
            ]
            topologyAwareHints = "true"
            topologySpreadConstraints = [
              {
                maxSkew           = 1
                topologyKey       = "topology.kubernetes.io/zone"
                whenUnsatisfiable = "DoNotSchedule"
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name" = "ecsdemo-crystal"
                  }
                }
              }
            ]
          }

          ecsdemoFrontend = {
            repoURL        = "https://github.com/allamand/ecsdemo-frontend"
            targetRevision = "main"
            #replicaCount   = "9" # see autoscaling configuration
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
              minReplicas                    = "9"
              maxReplicas                    = "100"
              targetCPUUtilizationPercentage = "60"
            }
            nodeSelector = {
              "karpenter.sh/provisioner-name" = "default"
            }
            tolerations = [
              {
                key      = "karpenter"
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

# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.tag_val_vpc]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${local.tag_val_private_subnet}*"]
  }
}

#Add Tags for the new cluster in the VPC Subnets
resource "aws_ec2_tag" "private_subnets" {
  for_each    = toset(data.aws_subnets.private.ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.environment}-${local.service}"
  value       = "shared"
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["${local.tag_val_public_subnet}*"]
  }
}

#Add Tags for the new cluster in the VPC Subnets
resource "aws_ec2_tag" "public_subnets" {
  for_each    = toset(data.aws_subnets.public.ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.environment}-${local.service}"
  value       = "shared"
}

# Create Sub HostedZone four our deployment
data "aws_route53_zone" "sub" {
  name = "${local.environment}.${local.hosted_zone_name}"
}


data "aws_secretsmanager_secret" "argocd" {
  name = "${local.argocd_secret_manager_name}.${local.environment}"
}

data "aws_secretsmanager_secret_version" "admin_password_version" {
  secret_id = data.aws_secretsmanager_secret.argocd.id
}

# data "aws_ecrpublic_authorization_token" "token" {
#   provider = aws.virginia
# }

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15.2"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = data.aws_vpc.vpc.id
  subnet_ids = data.aws_subnets.private.ids

  #we uses only 1 security group to allow connection with Fargate, MNG, and Karpenter nodes
  create_node_security_group = false
  eks_managed_node_groups = {
    initial = {
      node_group_name = local.node_group_name
      instance_types  = ["m5.large"]

      min_size     = 1
      max_size     = 5
      desired_size = 3
      subnet_ids   = data.aws_subnets.private.ids
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = flatten([
    [module.eks_blueprints_platform_teams.aws_auth_configmap_role],
    [for team in module.eks_blueprints_dev_teams : team.aws_auth_configmap_role],
    [{
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    }],
    [{
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.eks_admin_role_name}" # The ARN of the IAM role
      username = "ops-role"                                                                                      # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"]                                                                              # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }]
  ])

  tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = "${local.environment}-${local.service}"
  })
}

data "aws_iam_user" "platform_user" {
  count     = local.iam_platform_user != "" ? 1 : 0
  user_name = local.iam_platform_user
}

data "aws_iam_role" "eks_admin_role_name" {
  count = local.eks_admin_role_name != "" ? 1 : 0
  name  = local.eks_admin_role_name
}

module "eks_blueprints_platform_teams" {
  source  = "aws-ia/eks-blueprints-teams/aws"
  version = "~> 0.2"

  name = "team-platform"

  # Enables elevated, admin privileges for this team
  enable_admin = true

  # Define who can impersonate the team-platform Role
  users = [
    data.aws_caller_identity.current.arn,
    try(data.aws_iam_user.platform_user[0].arn, data.aws_caller_identity.current.arn),
    try(data.aws_iam_role.eks_admin_role_name[0].arn, data.aws_caller_identity.current.arn),
  ]
  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  labels = {
    "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
    "appName"                                 = "platform-team-app",
    "projectName"                             = "project-platform",
  }

  annotations = {
    team = "platform"
  }

  namespaces = {
    "team-platform" = {

      resource_quota = {
        hard = {
          "requests.cpu"    = "10000m",
          "requests.memory" = "20Gi",
          "limits.cpu"      = "20000m",
          "limits.memory"   = "50Gi",
          "pods"            = "20",
          "secrets"         = "20",
          "services"        = "20"
        }
      }

      limit_range = {
        limit = [
          {
            type = "Pod"
            max = {
              cpu    = "1000m"
              memory = "1Gi"
            },
            min = {
              cpu    = "10m"
              memory = "4Mi"
            }
          },
          {
            type = "PersistentVolumeClaim"
            min = {
              storage = "24M"
            }
          }
        ]
      }
    }

  }

  tags = local.tags
}

module "eks_blueprints_dev_teams" {
  source  = "aws-ia/eks-blueprints-teams/aws"
  version = "~> 0.2"

  for_each = {
    burnham = {
      labels = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "burnham-team-app",
        "projectName"                             = "project-burnham",
      }
    }
    riker = {
      labels = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "riker-team-app",
        "projectName"                             = "project-riker",
      }
    }
  }
  name = "team-${each.key}"

  users             = [data.aws_caller_identity.current.arn]
  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  labels = merge(
    {
      team = each.key
    },
    try(each.value.labels, {})
  )

  annotations = {
    team = each.key
  }

  namespaces = {
    "team-${each.key}" = {
      labels = merge(
        {
          team = each.key
        },
        try(each.value.labels, {})
      )

      resource_quota = {
        hard = {
          "requests.cpu"    = "100",
          "requests.memory" = "20Gi",
          "limits.cpu"      = "200",
          "limits.memory"   = "50Gi",
          "pods"            = "100",
          "secrets"         = "10",
          "services"        = "20"
        }
      }

      limit_range = {
        limit = [
          {
            type = "Pod"
            max = {
              cpu    = "2"
              memory = "1Gi"
            }
            min = {
              cpu    = "10m"
              memory = "4Mi"
            }
          },
          {
            type = "PersistentVolumeClaim"
            min = {
              storage = "24M"
            }
          },
          {
            type = "Container"
            default = {
              cpu    = "50m"
              memory = "24Mi"
            }
          }
        ]
      }
    }
  }

  tags = local.tags

}

module "eks_blueprints_ecsdemo_teams" {
  source  = "aws-ia/eks-blueprints-teams/aws"
  version = "~> 0.2"

  for_each = {
    ecsdemo-frontend = {}
    ecsdemo-nodejs   = {}
    ecsdemo-crystal  = {}
  }
  name = "team-${each.key}"

  users             = [data.aws_caller_identity.current.arn]
  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  labels = {
    "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
    "appName"                                 = "${each.key}-app",
    "projectName"                             = each.key,
    "environment"                             = "dev",
  }

  annotations = {
    team = each.key
  }

  namespaces = {
    (each.key) = {
      labels = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "${each.key}-app",
        "projectName"                             = each.key,
        "environment"                             = "dev",
      }

      resource_quota = {
        hard = {
          "requests.cpu"    = "100",
          "requests.memory" = "20Gi",
          "limits.cpu"      = "200",
          "limits.memory"   = "50Gi",
          "pods"            = "100",
          "secrets"         = "10",
          "services"        = "20"
        }
      }

      limit_range = {
        limit = [
          {
            type = "Pod"
            max = {
              cpu    = "2"
              memory = "1Gi"
            }
            min = {
              cpu    = "10m"
              memory = "4Mi"
            }
          },
          {
            type = "PersistentVolumeClaim"
            min = {
              storage = "24M"
            }
          },
          {
            type = "Container"
            default = {
              cpu    = "50m"
              memory = "24Mi"
            }
          }
        ]
      }
    }
  }

  tags = local.tags
}

module "kubernetes_addons" {
  source = "../../../../modules/kubernetes-addons"

  eks_cluster_id     = module.eks.cluster_name
  eks_cluster_domain = local.eks_cluster_domain

  #---------------------------------------------------------------
  # ARGO CD ADD-ON
  #---------------------------------------------------------------

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying Add-ons.

  argocd_applications = {
    addons    = local.addons_application
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
  # EKS Managed AddOns
  # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
  #---------------------------------------------------------------

  enable_amazon_eks_coredns = true
  amazon_eks_coredns_config = {
    most_recent        = true
    kubernetes_version = local.cluster_version
    resolve_conflicts  = "OVERWRITE"
  }

  enable_amazon_eks_aws_ebs_csi_driver = true
  amazon_eks_aws_ebs_csi_driver_config = {
    most_recent        = true
    kubernetes_version = local.cluster_version
    resolve_conflicts  = "OVERWRITE"
  }

  enable_amazon_eks_kube_proxy = true
  amazon_eks_kube_proxy_config = {
    most_recent        = true
    kubernetes_version = local.cluster_version
    resolve_conflicts  = "OVERWRITE"
  }

  enable_amazon_eks_vpc_cni = true
  amazon_eks_vpc_cni_config = {
    most_recent        = true
    kubernetes_version = local.cluster_version
    resolve_conflicts  = "OVERWRITE"
  }

  #---------------------------------------------------------------
  # ADD-ONS - You can add additional addons here
  # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
  #---------------------------------------------------------------

  enable_metrics_server               = local.metrics_server
  enable_vpa                          = local.vpa
  enable_aws_load_balancer_controller = local.aws_load_balancer_controller
  aws_load_balancer_controller_helm_config = {
    service_account = "aws-lb-sa"
  }
  enable_karpenter              = local.karpenter
  enable_aws_for_fluentbit      = local.aws_for_fluentbit
  enable_aws_cloudwatch_metrics = local.cloudwatch_metrics

  #to view the result : terraform state show 'module.kubernetes_addons.module.external_dns[0].module.helm_addon.helm_release.addon[0]'
  enable_external_dns = local.external_dns

  external_dns_helm_config = {
    txtOwnerId   = local.name
    zoneIdFilter = data.aws_route53_zone.sub.zone_id # Note: this uses GitOpsBridge
    policy       = "sync"
    logLevel     = "debug"
  }

  enable_kubecost      = local.kubecost
  enable_cert_manager  = local.cert_manager
  enable_argo_rollouts = local.argo_rollouts

}

######################################
#Work to update to new Addon repo
#But this break ArgoCD deployments so I comment temporarily here while working on new integration

# module "kubernetes_addons" {
#    # Users should pin the version to the latest available release
#      # tflint-ignore: terraform_module_pinned_source
#   source = "github.com/aws-ia/terraform-aws-eks-blueprints-addons?ref=70d10b15ad991c3a46fa405b56e76d3357f31ae1"
#   #version = "v1"

#   cluster_name      = module.eks.cluster_name
#   cluster_endpoint  = module.eks.cluster_endpoint
#   cluster_version   = module.eks.cluster_version
#   oidc_provider     = module.eks.cluster_oidc_issuer_url
#   oidc_provider_arn = module.eks.oidc_provider_arn

#   #---------------------------------------------------------------
#   # ARGO CD ADD-ON
#   #---------------------------------------------------------------

#   enable_argocd         = true
#   #https://github.com/helm/helm/pull/9426
#   #https://github.com/argoproj/argo-cd/issues/5202
#   #for now Argocd can't managed addons with new current repo
#   #argocd_manage_add_ons = false # Indicates that ArgoCD is responsible for managing/deploying Add-ons.

#   argocd_applications = {
#     addons    = local.addons_application
#     workloads = local.workload_application
#     ecsdemo   = local.ecsdemo_application
#   }

#   # This example shows how to set default ArgoCD Admin Password using SecretsManager with Helm Chart set_sensitive values.
#   argocd_helm_config = {
#     set_sensitive = [
#       {
#         name  = "configs.secret.argocdServerAdminPassword"
#         value = bcrypt(data.aws_secretsmanager_secret_version.admin_password_version.secret_string)
#       }
#     ]
#      # To have additional LB for Argo
#     set = [
#       {
#         name  = "server.service.type"
#         value = "LoadBalancer"
#       }
#     ]
#   }

#   #---------------------------------------------------------------
#   # EKS Managed AddOns
#   #---------------------------------------------------------------

#   eks_addons = {
#     aws-ebs-csi-driver = {
#       service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
#     }
#     coredns = {}
#     vpc-cni = {
#       service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
#       most_recent    = true
#       before_compute = true
#       configuration_values = jsonencode({
#         env = {
#           # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
#           ENABLE_PREFIX_DELEGATION = "true"
#           WARM_PREFIX_TARGET       = "1"
#         }
#       })
#     }
#     kube-proxy = {}
#   }


#   #---------------------------------------------------------------
#   # ADD-ONS - You can add additional addons here
#   # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
#   #---------------------------------------------------------------

#   enable_metrics_server               = local.metrics_server
#   enable_vpa                          = local.vpa
#   enable_aws_load_balancer_controller = local.aws_load_balancer_controller
#   aws_load_balancer_controller = {
#     service_account_name = "aws-lb-sa"
#   }
#   enable_karpenter              = local.karpenter
#   # ECR login required
#   karpenter = {
#     repository_username = data.aws_ecrpublic_authorization_token.token.user_name
#     repository_password = data.aws_ecrpublic_authorization_token.token.password
#   }
#   karpenter_instance_profile = {
#     iam_role_name = module.karpenter.role_name
#     name = module.karpenter.instance_profile_name
#     create = false
#   }
#   karpenter_enable_spot_termination = true

#   #enable_aws_for_fluentbit      = true
#   #enable_aws_cloudwatch_metrics = true

#   enable_external_dns = local.external_dns

#   #Needed to create Role
#   external_dns_route53_zone_arns = [
#     data.aws_route53_zone.sub.arn
#   ]
# #helm get all external-dns -n external-dns
#   external_dns = {
#     service_account_name = "external-dns-sa"
#     #chart_version = "1.12.2"
#     values = [
#       yamlencode({
#         txtOwnerId   = local.name
#         policy       = "sync"
#         logLevel     = "debug"
#         #domainFilters = [data.aws_route53_zone.sub.zone_id]
#         domainFilters = [local.eks_cluster_domain]
#       })
#     ]
#   }

#   #enable_kubecost = true
#   enable_argo_rollouts = local.argo_rollouts

# }

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
################################################################################
# Karpenter
################################################################################

# Creates Karpenter native node termination handler resources and IAM instance profile
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 19.15.1"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn
  create_irsa            = false # IRSA will be created by the kubernetes-addons module

  tags = local.tags
}
