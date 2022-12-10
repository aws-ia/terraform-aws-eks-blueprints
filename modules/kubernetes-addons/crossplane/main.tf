resource "kubernetes_namespace_v1" "crossplane" {
  count = try(local.helm_config["create_namespace"], true) && local.helm_config["namespace"] != "kube-system" ? 1 : 0
  metadata {
    name = local.namespace
  }
}

module "helm_addon" {
  source = "../helm-addon"

  helm_config   = local.helm_config
  addon_context = var.addon_context

  depends_on = [kubernetes_namespace_v1.crossplane]
}

#--------------------------------------
# AWS Provider
#--------------------------------------
module "aws_provider_irsa" {
  count                             = try(local.aws_provider.enable, true) ? 1 : 0
  source                            = "../../../modules/irsa"
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.namespace
  kubernetes_service_account        = "${local.aws_provider.name}-*"
  irsa_iam_policies                 = local.aws_provider.additional_irsa_policies
  irsa_iam_role_path                = var.addon_context.irsa_iam_role_path
  irsa_iam_permissions_boundary     = var.addon_context.irsa_iam_permissions_boundary
  eks_cluster_id                    = var.addon_context.eks_cluster_id
  eks_oidc_provider_arn             = var.addon_context.eks_oidc_provider_arn

}

resource "kubectl_manifest" "aws_controller_config" {
  count = try(local.aws_provider.enable, true) ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/aws-controller-config.yaml", {
    iam-role-arn          = module.aws_provider_irsa[0].irsa_iam_role_arn
    aws-controller-config = local.aws_provider.controller_config
  })

  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "aws_provider" {
  count = try(var.aws_provider.enable, true) ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/aws-provider.yaml", {
    provider-aws-version  = local.aws_provider.provider_aws_version
    aws-provider-name     = local.aws_provider.name
    aws-controller-config = local.aws_provider.controller_config
  })
  wait = true

  depends_on = [kubectl_manifest.aws_controller_config]
}

# Wait for the AWS Provider CRDs to be fully created before initiating aws_provider_config deployment
resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"

  depends_on = [kubectl_manifest.aws_provider]
}

resource "kubectl_manifest" "aws_provider_config" {
  count = local.aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/aws-provider-config.yaml", {
    aws-provider-config = local.aws_provider.provider_config
  })

  depends_on = [kubectl_manifest.aws_provider, time_sleep.wait_30_seconds]
}

#--------------------------------------
# Terrajet AWS Provider (Deprecated)
#--------------------------------------
resource "kubectl_manifest" "jet_aws_controller_config" {
  count = var.jet_aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/jet-aws-controller-config.yaml", {
    iam-role-arn = module.jet_aws_provider_irsa[0].irsa_iam_role_arn
  })

  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "jet_aws_provider" {
  count = var.jet_aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/jet-aws-provider.yaml", {
    provider-aws-version = var.jet_aws_provider.provider_aws_version
    aws-provider-name    = local.jet_aws_provider_sa
  })
  wait = true

  depends_on = [kubectl_manifest.jet_aws_controller_config]
}

module "jet_aws_provider_irsa" {
  count = var.jet_aws_provider.enable == true ? 1 : 0

  source                            = "../../../modules/irsa"
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.namespace
  kubernetes_service_account        = "${local.jet_aws_provider_sa}-*"
  irsa_iam_policies                 = concat([aws_iam_policy.jet_aws_provider[0].arn], var.jet_aws_provider.additional_irsa_policies)
  irsa_iam_role_path                = var.addon_context.irsa_iam_role_path
  irsa_iam_permissions_boundary     = var.addon_context.irsa_iam_permissions_boundary
  eks_cluster_id                    = var.addon_context.eks_cluster_id
  eks_oidc_provider_arn             = var.addon_context.eks_oidc_provider_arn

}

resource "aws_iam_policy" "jet_aws_provider" {
  count       = var.jet_aws_provider.enable == true ? 1 : 0
  description = "Crossplane Jet AWS Provider IAM policy"
  name        = "${var.addon_context.eks_cluster_id}-${local.jet_aws_provider_sa}-irsa"
  policy      = data.aws_iam_policy_document.s3_policy.json
  tags        = var.addon_context.tags
}

resource "kubectl_manifest" "jet_aws_provider_config" {
  count     = var.jet_aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/jet-aws-provider-config.yaml", {})

  depends_on = [kubectl_manifest.jet_aws_provider]
}

#--------------------------------------
# Kubernetes Provider
#--------------------------------------
resource "kubernetes_service_account_v1" "kubernetes_controller" {
  metadata {
    name      = local.kubernetes_provider.service_account
    namespace = local.namespace
  }

  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "kubernetes_controller_clusterolebinding" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/kubernetes-provider/kubernetes-controller-clusterrolebinding.yaml", {
    namespace                      = local.namespace
    cluster-role                   = local.kubernetes_provider.cluster_role
    kubernetes-serviceaccount-name = kubernetes_service_account_v1.kubernetes_controller.metadata[0].name
  })
  wait = true

  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "kubernetes_controller_config" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/kubernetes-provider/kubernetes-controller-config.yaml", {
    kubernetes-serviceaccount-name = kubernetes_service_account_v1.kubernetes_controller.metadata[0].name
    kubernetes-controller-config   = local.kubernetes_provider.controller_config
  })
  wait = true

  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "kubernetes_provider" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/kubernetes-provider/kubernetes-provider.yaml", {
    provider-kubernetes-version  = local.kubernetes_provider.provider_kubernetes_version
    kubernetes-provider-name     = local.kubernetes_provider.name
    kubernetes-controller-config = local.kubernetes_provider.controller_config
  })
  wait = true

  depends_on = [kubectl_manifest.kubernetes_controller_config]
}

# Wait for the AWS Provider CRDs to be fully created before initiating aws_provider_config deployment
resource "time_sleep" "wait_30_seconds_kubernetes" {
  create_duration = "30s"

  depends_on = [kubectl_manifest.kubernetes_provider]
}

resource "kubectl_manifest" "kubernetes_provider_config" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/kubernetes-provider/kubernetes-provider-config.yaml", {
    kubernetes-provider-config = local.kubernetes_provider.provider_config
  })

  depends_on = [kubectl_manifest.kubernetes_provider, time_sleep.wait_30_seconds_kubernetes]
}
