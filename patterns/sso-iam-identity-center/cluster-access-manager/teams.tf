
# Here why these datasources are needed:
# https://docs.aws.amazon.com/singlesignon/latest/userguide/referencingpermissionsets.html
# https://repost.aws/knowledge-center/eks-configure-sso-user

data "aws_iam_roles" "admin" {
  name_regex  = "AWSReservedSSO_EKSClusterAdmin_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"

  depends_on = [
    aws_ssoadmin_account_assignment.operators,
  ]
}

data "aws_iam_roles" "user" {
  name_regex  = "AWSReservedSSO_EKSClusterUser_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"

  depends_on = [
    aws_ssoadmin_account_assignment.developer
  ]
}

module "developers_team" {
  source  = "aws-ia/eks-blueprints-teams/aws"
  version = "1.1.0"

  name = "eks-developers"

  cluster_arn       = module.eks.cluster_arn
  oidc_provider_arn = module.eks.oidc_provider_arn

  create_iam_role = false
  principal_arns  = data.aws_iam_roles.user.arns

  labels = {
    team = "development"
  }

  annotations = {
    team = "development"
  }

  namespaces = {
    development = {
      labels = {
        projectName = "project-awesome",
      }

      resource_quota = {
        hard = {
          "requests.cpu"    = "1000m",
          "requests.memory" = "4Gi",
          "limits.cpu"      = "2000m",
          "limits.memory"   = "8Gi",
          "pods"            = "10",
          "secrets"         = "10",
          "services"        = "10"
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

      network_policy = {
        pod_selector = {
          match_expressions = [{
            key      = "name"
            operator = "In"
            values   = ["webfront", "api"]
          }]
        }

        ingress = [{
          ports = [
            {
              port     = "http"
              protocol = "TCP"
            },
            {
              port     = "53"
              protocol = "TCP"
            },
            {
              port     = "53"
              protocol = "UDP"
            }
          ]

          from = [
            {
              namespace_selector = {
                match_labels = {
                  name = "default"
                }
              }
            },
            {
              ip_block = {
                cidr = "10.0.0.0/8"
                except = [
                  "10.0.0.0/24",
                  "10.0.1.0/24",
                ]
              }
            }
          ]
        }]

        egress = [] # single empty rule to allow all egress traffic

        policy_types = ["Ingress", "Egress"]
      }
    }
  }

  tags = {
    Environment = "dev"
  }

  depends_on = [
    data.aws_iam_roles.admin,
    data.aws_iam_roles.user
  ]

}
