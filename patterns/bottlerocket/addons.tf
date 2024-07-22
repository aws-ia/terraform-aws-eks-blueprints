################################################################################
# EKS Blueprints Addons
################################################################################
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_cert_manager = true
  cert_manager = {
    wait          = true
    wait_for_jobs = true
    values = [<<-EOT
      tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Exists"
      cainjector:
        tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
      webhook:
        tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
      startupapicheck:
        tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
    EOT
    ]
  }

  enable_karpenter = true
  karpenter = {
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
    version             = "v0.36"
  }

  enable_bottlerocket_update_operator = true
  bottlerocket_update_operator = {
    values = [<<-EOT
      scheduler_cron_expression: "* * * * * * *"
      placement:
        agent:
          tolerations:
            - key: "CriticalAddonsOnly"
              operator: "Exists"
        controller:
          tolerations:
            - key: "CriticalAddonsOnly"
              operator: "Exists"
        apiserver:
          tolerations:
            - key: "CriticalAddonsOnly"
              operator: "Exists"
    EOT
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
