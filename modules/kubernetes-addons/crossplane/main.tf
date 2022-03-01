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
  context           = var.context

  depends_on = [kubernetes_namespace_v1.crossplane]
}

resource "kubectl_manifest" "controller_config" {
  yaml_body = templatefile("${path.module}/aws-provider/controller-config.yaml", {
    iam-role-arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.eks_cluster_id}-provider-aws--irsa"
  })
  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "aws_provider" {
  yaml_body = templatefile("${path.module}/aws-provider/provider-aws.yaml", {
    provider-aws-version = var.crossplane_provider_aws.provider_aws_version
  })
  depends_on = [kubectl_manifest.controller_config]
}

module "aws_provider_irsa" {
  source                            = "../../../modules/irsa"
  eks_cluster_id                    = var.eks_cluster_id
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.namespace
  kubernetes_service_account        = "provider-aws-*"
  irsa_iam_policies                 = concat([aws_iam_policy.aws_provider.arn], var.crossplane_provider_aws.additional_irsa_policies)
  tags                              = var.tags
  context                           = var.context

  depends_on = [kubectl_manifest.aws_provider]
}

resource "aws_iam_policy" "aws_provider" {
  description = "Crossplane AWS Provider IAM policy"
  name        = "${var.eks_cluster_id}-aws-provider-irsa"
  policy      = data.aws_iam_policy_document.s3_policy.json
  tags        = var.tags
}

# Wait for the AWS Provider CRDs to be fully created before initiating aws_provider_config deployment
resource "time_sleep" "wait_30_seconds" {
  depends_on = [kubectl_manifest.aws_provider]

  create_duration = "30s"
}

resource "kubectl_manifest" "aws_provider_config" {
  yaml_body = templatefile("${path.module}/aws-provider/aws-provider-config.yaml", {})

  depends_on = [kubectl_manifest.aws_provider, time_sleep.wait_30_seconds]
}
