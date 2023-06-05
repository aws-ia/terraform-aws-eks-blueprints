resource "random_string" "id" {
  length  = 4
  special = false
  upper   = false
}

locals {
  name                 = "portworx-${random_string.id.result}"
  namespace            = "kube-system"
  service_account_name = "${local.name}-sa-${random_string.id.result}"

  aws_marketplace_config = try(var.helm_config["set"][index(var.helm_config.set[*].name, "aws.marketplace")], null)
  use_aws_marketplace    = local.aws_marketplace_config != null ? local.aws_marketplace_config["value"] : false

  default_helm_config = {
    name        = local.name
    description = "A Helm chart for portworx"
    chart       = "portworx"
    repository  = "https://raw.githubusercontent.com/portworx/eks-blueprint-helm/main/repo/stable"
    version     = "2.11.0"
    namespace   = local.namespace
    values      = local.default_helm_values
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  irsa_iam_policies_list = local.use_aws_marketplace != false ? [aws_iam_policy.portworx_eksblueprint_metering[0].arn] : []

  irsa_config = {
    create_kubernetes_namespace       = false
    kubernetes_namespace              = local.namespace
    create_kubernetes_service_account = true
    kubernetes_service_account        = local.service_account_name
    irsa_iam_policies                 = local.irsa_iam_policies_list
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    imageVersion           = "2.11.0"
    clusterName            = local.name
    drives                 = "type=gp2,size=200"
    useInternalKVDB        = true
    kvdbDevice             = "type=gp2,size=150"
    envVars                = ""
    maxStorageNodesPerZone = 3
    useOpenshiftInstall    = false
    etcdEndPoint           = ""
    dataInterface          = ""
    managementInterface    = ""
    useStork               = true
    storkVersion           = "2.11.0"
    customRegistryURL      = ""
    registrySecret         = ""
    licenseSecret          = ""
    monitoring             = false
    enableCSI              = false
    enableAutopilot        = false
    KVDBauthSecretName     = ""
    eksServiceAccount      = local.service_account_name
    awsAccessKeyId         = ""
    awsSecretAccessKey     = ""
    deleteType             = "UninstallAndWipe"
    }
  )]
}

resource "aws_iam_policy" "portworx_eksblueprint_metering" {
  count = try(local.use_aws_marketplace, false) ? 1 : 0
  name  = "portworx_eksblueprint_metering-${random_string.id.result}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "aws-marketplace:MeterUsage",
          "aws-marketplace:RegisterUsage"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}
