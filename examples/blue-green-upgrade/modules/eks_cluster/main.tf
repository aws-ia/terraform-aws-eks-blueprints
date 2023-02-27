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

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.18.1"

  cluster_name = local.name

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = data.aws_vpc.vpc.id
  private_subnet_ids = data.aws_subnets.private.ids

  # EKS CONTROL PLANE VARIABLES
  cluster_version = local.cluster_version

  # List of map_roles
  map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_admin_role_name}" # The ARN of the IAM role
      username = "ops-role"                                                                                    # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"]                                                                            # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ]

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_5 = {
      node_group_name = local.node_group_name
      instance_types  = ["m5.xlarge"]
      min_size        = 3
      subnet_ids      = data.aws_subnets.private.ids
    }
  }

  platform_teams = {
    admin = {
      users = [
        data.aws_caller_identity.current.arn,
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${var.iam_platform_user}",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_admin_role_name}"
      ]
    }
  }

  application_teams = {

    team-burnham = {
      "labels" = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "burnham-team-app",
        "projectName"                             = "project-burnham",
        "environment"                             = "dev",
        "domain"                                  = "example",
        "uuid"                                    = "example",
        "billingCode"                             = "example",
        "branch"                                  = "example"
      }
      "quota" = {
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
      users         = [data.aws_caller_identity.current.arn]
    }

    team-riker = {
      "labels" = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "riker-team-app",
        "projectName"                             = "project-riker",
        "environment"                             = "dev",
        "domain"                                  = "example",
        "uuid"                                    = "example",
        "billingCode"                             = "example",
        "branch"                                  = "example"
      }
      "quota" = {
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
      users         = [data.aws_caller_identity.current.arn]
    }


    ecsdemo-frontend = {
      "labels" = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "ecsdemo-frontend-app",
        "projectName"                             = "ecsdemo-frontend",
        "environment"                             = "dev",
      }
      #don't use quotas here cause ecsdemo app does not have request/limits
      "quota" = {
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
      users         = [data.aws_caller_identity.current.arn]
    }
    ecsdemo-nodejs = {
      "labels" = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "ecsdemo-nodejs-app",
        "projectName"                             = "ecsdemo-nodejs",
        "environment"                             = "dev",
      }
      #don't use quotas here cause ecsdemo app does not have request/limits
      "quota" = {
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
      users         = [data.aws_caller_identity.current.arn]
    }
    ecsdemo-crystal = {
      "labels" = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "ecsdemo-crystal-app",
        "projectName"                             = "ecsdemo-crystal",
        "environment"                             = "dev",
      }
      #don't use quotas here cause ecsdemo app does not have request/limits
      "quota" = {
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
      users         = [data.aws_caller_identity.current.arn]
    }
  }

  tags = local.tags
}

#certificate_arn = aws_acm_certificate_validation.example.certificate_arn

module "kubernetes_addons" {
  source             = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.18.1/modules/kubernetes-addons"
  eks_cluster_id     = module.eks_blueprints.eks_cluster_id
  eks_cluster_domain = local.eks_cluster_domain

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

  enable_kubecost = true

}
