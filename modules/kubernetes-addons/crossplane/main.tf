resource "kubernetes_namespace_v1" "crossplane" {
  metadata {
    name = local.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform-ssp-amazon-eks"
    }
  }
}

module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  irsa_config       = null

  depends_on = [kubernetes_namespace_v1.crossplane]
}

#--------------------------------------
# AWS Provider
#--------------------------------------
resource "kubectl_manifest" "aws_controller_config" {
  count = var.aws_provider.enable == true ? 1 : 0

  yaml_body = templatefile("${path.module}/aws-provider/aws-controller-config.yaml", {
    iam-role-arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_id}-${local.aws_provider_sa}-irsa"
  })
  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "aws_provider" {
  count = var.aws_provider.enable == true ? 1 : 0

  yaml_body = templatefile("${path.module}/aws-provider/aws-provider.yaml", {
    provider-aws-version = var.aws_provider.provider_aws_version
    aws-provider-name    = local.aws_provider_sa
  })
  depends_on = [kubectl_manifest.aws_controller_config]
}

module "aws_provider_irsa" {
  count = var.aws_provider.enable == true ? 1 : 0

  source                            = "../../../modules/irsa"
  eks_cluster_id                    = var.eks_cluster_id
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.namespace
  kubernetes_service_account        = "${local.aws_provider_sa}-*"
  irsa_iam_policies                 = concat([aws_iam_policy.aws_provider[0].arn], var.aws_provider.additional_irsa_policies)
  tags                              = var.tags

  depends_on = [kubectl_manifest.aws_provider]
}

resource "aws_iam_policy" "aws_provider" {
  count = var.aws_provider.enable == true ? 1 : 0

  description = "Crossplane AWS Provider IAM policy"
  name        = "${var.eks_cluster_id}-${local.aws_provider_sa}-irsa"
  policy      = data.aws_iam_policy_document.s3_policy.json
  tags        = var.tags
}

resource "kubectl_manifest" "aws_provider_config" {
  count = var.aws_provider.enable == true ? 1 : 0

  yaml_body = templatefile("${path.module}/aws-provider/aws-provider-config.yaml", {})

  depends_on = [kubectl_manifest.aws_provider, time_sleep.wait_30_seconds_aws]
}

# Wait for the AWS Provider CRDs to be fully created before initiating aws_provider_config deployment
resource "time_sleep" "wait_30_seconds_aws" {
  count = var.aws_provider.enable == true ? 1 : 0

  create_duration = "30s"
  depends_on = [kubectl_manifest.aws_provider]
}
#--------------------------------------
# Terrajet AWS Provider
#--------------------------------------
resource "kubectl_manifest" "jet_aws_controller_config" {
  count = var.jet_aws_provider.enable == true ? 1 : 0

  yaml_body = templatefile("${path.module}/aws-provider/jet-aws-controller-config.yaml", {
    iam-role-arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_id}-${local.jet_aws_provider_sa}-irsa"
  })

  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "jet_aws_provider" {
  count = var.jet_aws_provider.enable == true ? 1 : 0

  yaml_body = templatefile("${path.module}/aws-provider/jet-aws-provider.yaml", {
    provider-aws-version = var.jet_aws_provider.provider_aws_version
    aws-provider-name    = local.jet_aws_provider_sa
  })

  depends_on = [kubectl_manifest.jet_aws_controller_config]
}

module "jet_aws_provider_irsa" {
  count = var.jet_aws_provider.enable == true ? 1 : 0

  source                            = "../../../modules/irsa"
  eks_cluster_id                    = var.eks_cluster_id
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.namespace
  kubernetes_service_account        = "${local.jet_aws_provider_sa}-*"
  irsa_iam_policies                 = concat([aws_iam_policy.jet_aws_provider[0].arn], var.jet_aws_provider.additional_irsa_policies)
  tags                              = var.tags

  depends_on = [kubectl_manifest.jet_aws_provider]
}

resource "aws_iam_policy" "jet_aws_provider" {
  count = var.jet_aws_provider.enable == true ? 1 : 0

  description = "Crossplane Jet AWS Provider IAM policy"
  name        = "${var.eks_cluster_id}-${local.jet_aws_provider_sa}-irsa"
  policy      = data.aws_iam_policy_document.s3_policy.json
  tags        = var.tags
}

resource "kubectl_manifest" "jet_aws_provider_config" {
  count = var.jet_aws_provider.enable == true ? 1 : 0

  yaml_body = templatefile("${path.module}/aws-provider/jet-aws-provider-config.yaml", {})

  depends_on = [kubectl_manifest.jet_aws_provider, time_sleep.wait_30_seconds_jet_aws]
}

# Wait for the AWS Provider CRDs to be fully created before initiating jet_aws_provider_config deployment
resource "time_sleep" "wait_30_seconds_jet_aws" {
  count = var.jet_aws_provider.enable == true ? 1 : 0

  create_duration = "30s"
  depends_on = [kubectl_manifest.jet_aws_provider]
}