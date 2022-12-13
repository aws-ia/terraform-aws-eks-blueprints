locals {
  core_stack_name   = var.core_stack_name
  suffix_stack_name = "green"
  env               = "dev" # use to suffix some kubernetes objects
  name              = "${var.core_stack_name}-${local.suffix_stack_name}"

  eks_cluster_domain = "${local.core_stack_name}.${var.hosted_zone_name}" # for external-dns

  cluster_version = "1.24"

  # Route 53 Ingress Weights
  argocd_route53_weight      = "0"
  route53_weight             = "0"
  ecsfrontend_route53_weight = "0"

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
