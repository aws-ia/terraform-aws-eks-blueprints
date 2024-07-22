################################################################################
# EKS Blueprints Addons
################################################################################
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.15"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_cert_manager = true
  cert_manager = {
    wait          = true
    wait_for_jobs = true
    set = [{
      name  = "tolerations[0].key"
      value = "CriticalAddonsOnly"
      },
      {
        name  = "tolerations[0].operator"
        value = "Exists"
      },
      {
        name  = "cainjector.tolerations[0].key"
        value = "CriticalAddonsOnly"
      },
      {
        name  = "cainjector.tolerations[0].operator"
        value = "Exists"
      },
      {
        name  = "webhook.tolerations[0].key"
        value = "CriticalAddonsOnly"
      },
      {
        name  = "webhook.tolerations[0].operator"
        value = "Exists"
      },
      {
        name  = "startupapicheck.tolerations[0].key"
        value = "CriticalAddonsOnly"
      },
      {
        name  = "startupapicheck.tolerations[0].operator"
        value = "Exists"
    }]
  }

  enable_karpenter = true
  karpenter = {
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
    version             = "v0.36"
  }

  enable_bottlerocket_update_operator = true
  bottlerocket_update_operator = {
    set = [{
      name  = "scheduler_cron_expression"
      value = "0 * * * * * *" # Default Unix Cron syntax, set to check every hour. Example "0 0 23 * * Sat *" Perform update checks every Saturday at 23H / 11PM
      },
      {
        name  = "placement.agent.tolerations[0].key"
        value = "CriticalAddonsOnly"
      },
      {
        name  = "placement.agent.tolerations[0].operator"
        value = "Exists"
      },
      {
        name  = "placement.controller.tolerations[0].key"
        value = "CriticalAddonsOnly"
      },
      {
        name  = "placement.controller.tolerations[0].operator"
        value = "Exists"
      },
      {
        name  = "placement.apiserver.tolerations[0].key"
        value = "CriticalAddonsOnly"
      },
      {
        name  = "placement.apiserver.tolerations[0].operator"
        value = "Exists"
      }
    ]
  }

  tags = local.tags
}

################################################################################
# Karpenter resources
################################################################################
resource "aws_eks_access_entry" "karpenter" {

  cluster_name  = module.eks.cluster_name
  principal_arn = module.eks_blueprints_addons.karpenter.node_iam_role_arn
  type          = "EC2_LINUX"

  tags = local.tags

  depends_on = [module.eks_blueprints_addons]
  }


resource "helm_release" "karpenter_resources" {
  name  = "karpenter-resources"
  chart = "./karpenter-resources"
  set_list {
    name  = "nodepool.zone"
    value = local.azs
  }
  values = [<<-EOT
    ec2nodeclass:
      securityGroupSelectorTerms: 
        tags: ${module.eks.cluster_name}
      subnetSelectorTerms: 
        tags: ${module.eks.cluster_name}
      tags: ${module.eks.cluster_name}
      role: ${split("/", module.eks_blueprints_addons.karpenter.node_iam_role_arn)[1]}
      blockDeviceMappings:
        ebs:
          kmsKeyID: ${module.ebs_kms_key.key_id}
  EOT
  ]

  depends_on = [module.eks_blueprints_addons]
}
