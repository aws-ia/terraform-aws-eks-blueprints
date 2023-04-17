locals {
  environment = var.environment_name
  service     = var.service_name

  env  = var.environment_name
  name = "${local.environment}-${local.service}"

  eks_cluster_domain = "${local.environment}.${var.hosted_zone_name}" # for external-dns

  cluster_version = var.cluster_version

  # Route 53 Ingress Weights
  argocd_route53_weight      = var.argocd_route53_weight
  route53_weight             = var.route53_weight
  ecsfrontend_route53_weight = var.ecsfrontend_route53_weight

  tag_val_vpc            = local.environment
  tag_val_public_subnet  = "${local.environment}-public-"
  tag_val_private_subnet = "${local.environment}-private-"

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
          ecsdemoNodejs  = {
            replicaCount   = "9"
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

          ecsdemoCrystal  = {
            replicaCount   = "9"
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


data "aws_partition" "current" {}

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

# Create Sub HostedZone four our deployment
data "aws_route53_zone" "sub" {
  name = "${var.environment_name}.${var.hosted_zone_name}"
}


data "aws_secretsmanager_secret" "argocd" {
  name = "${local.argocd_secret_manager_name}.${local.environment}"
}

data "aws_secretsmanager_secret_version" "admin_password_version" {
  secret_id = data.aws_secretsmanager_secret.argocd.id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.12"

  cluster_name = local.name
  cluster_version = local.cluster_version
  cluster_endpoint_public_access = true

  vpc_id             = data.aws_vpc.vpc.id
  subnet_ids = data.aws_subnets.private.ids

  eks_managed_node_groups = {
    initial = {
      node_group_name = local.node_group_name
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 5
      desired_size = 3
      subnet_ids      = data.aws_subnets.private.ids
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = flatten([
    module.eks_blueprints_admin_team.aws_auth_configmap_role,
    [for team in module.eks_blueprints_dev_teams : team.aws_auth_configmap_role],
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_admin_role_name}" # The ARN of the IAM role
      username = "ops-role"                                                                                    # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"]                                                                            # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ])

  # List of map_roles
  # map_roles = [
  #   {
  #     rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_admin_role_name}" # The ARN of the IAM role
  #     username = "ops-role"                                                                                    # The user name within Kubernetes to map to the IAM role
  #     groups   = ["system:masters"]                                                                            # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
  #   }
  # ]

  # EKS MANAGED NODE GROUPS
  # managed_node_groups = {
  #   mg_5 = {
  #     node_group_name = local.node_group_name
  #     instance_types  = ["m5.large"]
  #     min_size        = 3
  #     subnet_ids      = data.aws_subnets.private.ids
  #   }
  # }

  # platform_teams = {
  #   admin = {
  #     users = [
  #       data.aws_caller_identity.current.arn,
  #       "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${var.iam_platform_user}",
  #       "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_admin_role_name}"
  #     ]
  #   }
  # }

  # application_teams = {
  #   team-platform = {
  #     "labels" = {
  #       "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
  #       "appName"                                 = "platform-team-app",
  #       "projectName"                             = "project-platform",
  #     }
  #     "quota" = {
  #       "requests.cpu"    = "10000m",
  #       "requests.memory" = "20Gi",
  #       "limits.cpu"      = "20000m",
  #       "limits.memory"   = "50Gi",
  #       "pods"            = "10",
  #       "secrets"         = "10",
  #       "services"        = "10"
  #     }
  #     ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
  #     manifests_dir = "../kubernetes/team-platform/"
  #     users         = [data.aws_caller_identity.current.arn]
  #   }

  #   team-burnham = {
  #     "labels" = {
  #       "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
  #       "appName"                                 = "burnham-team-app",
  #       "projectName"                             = "project-burnham",
  #       "environment"                             = "dev",
  #     }
  #     "quota" = {
  #       "requests.cpu"    = "20k",
  #       "requests.memory" = "20000Gi",
  #       "limits.cpu"      = "40k",
  #       "limits.memory"   = "50000Gi",
  #       "pods"            = "10k",
  #       "secrets"         = "10k",
  #       "services"        = "10k"
  #     }
  #     manifests_dir = "../kubernetes/team-burnham/"
  #     users         = [data.aws_caller_identity.current.arn]
  #   }

  #   team-riker = {
  #     "labels" = {
  #       "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
  #       "appName"                                 = "riker-team-app",
  #       "projectName"                             = "project-riker",
  #       "environment"                             = "dev",
  #       "domain"                                  = "example",
  #       "uuid"                                    = "example",
  #       "billingCode"                             = "example",
  #       "branch"                                  = "example"
  #     }
  #     "quota" = {
  #       "requests.cpu"    = "10000m",
  #       "requests.memory" = "20Gi",
  #       "limits.cpu"      = "20000m",
  #       "limits.memory"   = "50Gi",
  #       "pods"            = "10",
  #       "secrets"         = "10",
  #       "services"        = "10"
  #     }
  #     ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
  #     manifests_dir = "../kubernetes/team-riker/"
  #     users         = [data.aws_caller_identity.current.arn]
  #   }


  #   ecsdemo-frontend = {
  #     "labels" = {
  #       "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
  #       "appName"                                 = "ecsdemo-frontend-app",
  #       "projectName"                             = "ecsdemo-frontend",
  #       "environment"                             = "dev",
  #     }
  #     #don't use quotas here cause ecsdemo app does not have request/limits
  #     "quota" = {
  #       "requests.cpu"    = "100",
  #       "requests.memory" = "20Gi",
  #       "limits.cpu"      = "200",
  #       "limits.memory"   = "50Gi",
  #       "pods"            = "100",
  #       "secrets"         = "10",
  #       "services"        = "20"
  #     }
  #     ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
  #     manifests_dir = "../kubernetes/ecsdemo-frontend/"
  #     users         = [data.aws_caller_identity.current.arn]
  #   }
  #   ecsdemo-nodejs = {
  #     "labels" = {
  #       "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
  #       "appName"                                 = "ecsdemo-nodejs-app",
  #       "projectName"                             = "ecsdemo-nodejs",
  #       "environment"                             = "dev",
  #     }
  #     #don't use quotas here cause ecsdemo app does not have request/limits
  #     "quota" = {
  #       "requests.cpu"    = "10000m",
  #       "requests.memory" = "20Gi",
  #       "limits.cpu"      = "20000m",
  #       "limits.memory"   = "50Gi",
  #       "pods"            = "20",
  #       "secrets"         = "10",
  #       "services"        = "10"
  #     }
  #     ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
  #     manifests_dir = "../kubernetes/ecsdemo-nodejs"
  #     users         = [data.aws_caller_identity.current.arn]
  #   }
  #   ecsdemo-crystal = {
  #     "labels" = {
  #       "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
  #       "appName"                                 = "ecsdemo-crystal-app",
  #       "projectName"                             = "ecsdemo-crystal",
  #       "environment"                             = "dev",
  #     }
  #     #don't use quotas here cause ecsdemo app does not have request/limits
  #     "quota" = {
  #       "requests.cpu"    = "10000m",
  #       "requests.memory" = "20Gi",
  #       "limits.cpu"      = "20000m",
  #       "limits.memory"   = "50Gi",
  #       "pods"            = "20",
  #       "secrets"         = "10",
  #       "services"        = "10"
  #     }
  #     ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
  #     manifests_dir = "../kubernetes/ecsdemo-crystal"
  #     users         = [data.aws_caller_identity.current.arn]
  #   }
  # }

  tags = local.tags
}

module "eks_blueprints_admin_team" {
  source  = "aws-ia/eks-blueprints-teams/aws"
  version = "~> 0.2"

  name = "admin-team"

  enable_admin = true
  users = [
    data.aws_caller_identity.current.arn,
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${var.iam_platform_user}",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_admin_role_name}"
  ]
  cluster_arn  = module.eks.cluster_arn

  tags = local.tags
}

module "eks_blueprints_platform_teams" {
  source  = "aws-ia/eks-blueprints-teams/aws"
  version = "~> 0.2"

  for_each = {
    platform = {
      labels = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "platform-team-app",
        "projectName"                             = "project-platform",        
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
      labels =  merge(
      {
        team = each.key
      },
      try(each.value.labels, {})
      )

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
              cpu    = "200m"
              memory = "1Gi"
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

    ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
    #manifests_dir = "../kubernetes/team-burnham/"
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
      labels =  merge(
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
    ecsdemo-nodejs = {}  
    ecsdemo-crystal = {}        
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
    "downscaler/uptime"                       = "Mon-Fri_0900-1700_CET",
    //validation regex '(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?')
    //"downscaler/downtime"                     = "Sat-Sun 00:00-24:00 CET,Fri-Fri 20:00-24:00 CET",    
  }

  annotations = {
    team = each.key
  }

  namespaces = {
    "${each.key}" = {
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
   # Users should pin the version to the latest available release
     # tflint-ignore: terraform_module_pinned_source
  source = "github.com/aws-ia/terraform-aws-eks-blueprints-addons"
  #version = "v1"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider     = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn = module.eks.oidc_provider_arn

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
     # To have additional LB for Argo
    set = [
      {
        name  = "server.service.type"
        value = "LoadBalancer"
      }
    ]
  }

  #---------------------------------------------------------------
  # EKS Managed AddOns
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
  #aws_load_balancer_controller_helm_config = {
  #  service_account = "aws-lb-sa"
  #}
  enable_karpenter              = true
  #karpenter_node_iam_instance_profile        = module.karpenter.instance_profile_name
  #karpenter_enable_spot_termination_handling = true

  enable_aws_for_fluentbit      = true
  #enable_aws_cloudwatch_metrics = true

  enable_external_dns = true

  #external_dns_helm_config = {
  #  txtOwnerId   = local.name
  #  zoneIdFilter = data.aws_route53_zone.sub.zone_id # Note: this uses GitOpsBridge
  #  policy       = "sync"
  #  logLevel     = "debug"
  #}

  #enable_kubecost = true
  enable_argo_rollouts = true

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
################################################################################
# Karpenter
################################################################################

# Creates Karpenter native node termination handler resources and IAM instance profile
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 19.12"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn
  create_irsa            = false # IRSA will be created by the kubernetes-addons module

  tags = local.tags
}