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
resource "kubectl_manifest" "aws_controller_config" {
  count = local.aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/aws-controller-config.yaml", {
    iam-role-arn          = "arn:${var.addon_context.aws_partition_id}:iam::${var.addon_context.aws_caller_identity_account_id}:role/${var.addon_context.eks_cluster_id}-${local.aws_provider.name}-irsa"
    aws-controller-config = local.aws_provider.controller_config
  })
  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "aws_provider" {
  count = local.aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/aws-provider.yaml", {
    provider-aws-version  = local.aws_provider.provider_aws_version
    aws-provider-name     = local.aws_provider.name
    aws-controller-config = local.aws_provider.controller_config
  })
  wait       = true
  depends_on = [kubectl_manifest.aws_controller_config]
}

# Wait for the AWS Provider CRDs to be fully created before initiating aws_provider_config deployment
resource "time_sleep" "wait_30_seconds" {
  depends_on = [kubectl_manifest.aws_provider]

  create_duration = "30s"
}

module "aws_provider_irsa" {
  count                             = local.aws_provider.enable == true ? 1 : 0
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
  depends_on                        = [kubectl_manifest.aws_provider]
}

resource "kubectl_manifest" "aws_provider_config" {
  count = local.aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/aws-provider-config.yaml", {
    aws-provider-config          = local.aws_provider.provider_config
  })

  depends_on = [kubectl_manifest.aws_provider, time_sleep.wait_30_seconds]
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
    kubernetes-serviceaccount-name = local.kubernetes_provider.service_account
  })
  wait = true

  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "kubernetes_controller_config" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/kubernetes-provider/kubernetes-controller-config.yaml", {
    kubernetes-serviceaccount-name = local.kubernetes_provider.service_account
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

resource "kubectl_manifest" "kubernetes_provider_config" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/kubernetes-provider/kubernetes-provider-config.yaml", {
    kubernetes-provider-config = local.kubernetes_provider.provider_config
  })

  depends_on = [kubectl_manifest.kubernetes_provider]
}
