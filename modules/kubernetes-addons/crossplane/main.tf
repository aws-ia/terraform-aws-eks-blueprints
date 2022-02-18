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

resource "kubectl_manifest" "controller_config" {
  yaml_body = templatefile("${path.module}/aws-provider/controller-config.yaml", {
    iam-role-arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_id}-provider-aws--irsa"
  })
  depends_on = [module.helm_addon]
}

#--------------------------------------
# AWS Provider
#--------------------------------------
resource "kubectl_manifest" "aws_provider" {
  count = local.provider_aws.enable == true ? 1 : 0

  yaml_body = templatefile("${path.module}/aws-provider/provider-aws.yaml", {
    provider-aws-version = var.provider_aws.provider_aws_version
  })
  depends_on = [kubectl_manifest.controller_config]
}

module "aws_provider_irsa" {
  count = local.provider_aws.enable == true ? 1 : 0

  source                            = "../../../modules/irsa"
  eks_cluster_id                    = var.eks_cluster_id
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.namespace
  kubernetes_service_account        = "provider-aws-*"
  irsa_iam_policies                 = concat([aws_iam_policy.aws_provider[0].arn], local.provider_aws.additional_irsa_policies)
  tags                              = var.tags

  depends_on = [kubectl_manifest.aws_provider]
}

resource "aws_iam_policy" "aws_provider" {
  count = local.provider_aws.enable == true ? 1 : 0

  description = "Crossplane AWS Provider IAM policy"
  name        = "${var.eks_cluster_id}-xplane-aws-provider-irsa"
  policy      = data.aws_iam_policy_document.s3_policy.json
  tags        = var.tags
}

# Wait for the AWS Provider CRDs to be fully created before initiating aws_provider_config deployment
resource "time_sleep" "wait_30_seconds" {
  count = local.provider_aws.enable == true ? 1 : 0

  depends_on = [kubectl_manifest.aws_provider]

  create_duration = "30s"
}

resource "kubectl_manifest" "aws_provider_config" {
  count = local.provider_aws.enable == true ? 1 : 0

  yaml_body = templatefile("${path.module}/aws-provider/aws-provider-config.yaml", {})

  depends_on = [kubectl_manifest.aws_provider, time_sleep.wait_30_seconds]
}

#--------------------------------------
# Terrajet AWS Provider
#--------------------------------------
