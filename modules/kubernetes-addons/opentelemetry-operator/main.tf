module "cert_manager" {
  source = "../cert-manager"

  # https://docs.aws.amazon.com/eks/latest/userguide/adot-reqts.html
  # certmanaager v1.6.0 onwards is not supported yet
  helm_config   = { version = "v1.5.0" }
  addon_context = var.addon_context
}

resource "kubernetes_namespace_v1" "adot" {
  count = local.create_namespace ? 1 : 0

  metadata {
    # If using EKS addon, namespace must be "opentelemetry-operator-system"
    name = var.enable_amazon_eks_adot ? local.addon_namespace : try(var.helm_config.namespace, local.addon_namespace)

    labels = {
      # Prerequisite for EKS addon
      "control-plane" = "controller-manager"
    }
  }
}

data "aws_eks_addon_version" "this" {
  count = var.enable_amazon_eks_adot ? 1 : 0

  addon_name = local.name
  # Need to allow both config routes - for managed and self-managed configs
  kubernetes_version = try(var.addon_config.kubernetes_version, var.helm_config.kubernetes_version)
  most_recent        = try(var.addon_config.most_recent, var.helm_config.most_recent, true)
}

resource "aws_eks_addon" "adot" {
  count = var.enable_amazon_eks_adot ? 1 : 0

  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = local.name
  addon_version            = try(var.addon_config.addon_version, data.aws_eks_addon_version.this[0].version)
  resolve_conflicts        = try(var.addon_config.resolve_conflicts, "OVERWRITE")
  service_account_role_arn = try(var.addon_config.service_account_role_arn, null)
  preserve                 = try(var.addon_config.preserve, true)

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {}),
    # implicit dependency with roles
    {
      RoleVersion        = try(kubernetes_role_v1.adot[0].metadata[0].resource_version, ""),
      ClusterRoleVersion = try(kubernetes_cluster_role_v1.adot[0].metadata[0].resource_version, "")
    }
  )

  depends_on = [module.cert_manager]
}

resource "kubernetes_role_v1" "adot" {
  count = var.enable_amazon_eks_adot ? 1 : 0

  metadata {
    name      = local.eks_addon_role_name
    namespace = kubernetes_namespace_v1.adot[0].metadata[0].name
  }

  rule {
    api_groups     = [""]
    resources      = ["serviceaccounts"]
    resource_names = ["opentelemetry-operator-controller-manager"]
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups     = ["rbac.authorization.k8s.io"]
    resources      = ["roles"]
    resource_names = ["opentelemetry-operator-leader-election-role"]
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups     = ["rbac.authorization.k8s.io"]
    resources      = ["rolebindings"]
    resource_names = ["opentelemetry-operator-leader-election-rolebinding"]
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups     = [""]
    resources      = ["services"]
    resource_names = ["opentelemetry-operator-controller-manager-metrics-service", "opentelemetry-operator-webhook-service"]
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups     = ["apps"]
    resources      = ["deployments"]
    resource_names = ["opentelemetry-operator-controller-manager"]
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups     = ["cert-manager.io"]
    resources      = ["certificates", "issuers"]
    resource_names = ["opentelemetry-operator-serving-cert", "opentelemetry-operator-selfsigned-issuer"]
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps/status"]
    verbs      = ["get", "update", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["list"]
  }
}

resource "kubernetes_role_binding_v1" "adot" {
  count = var.enable_amazon_eks_adot ? 1 : 0

  metadata {
    name      = local.eks_addon_role_name
    namespace = kubernetes_namespace_v1.adot[0].metadata[0].name
  }

  subject {
    kind      = "User"
    name      = local.eks_addon_role_name
    api_group = "rbac.authorization.k8s.io"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = local.eks_addon_role_name
  }
}

resource "kubernetes_cluster_role_v1" "adot" {
  count = var.enable_amazon_eks_adot ? 1 : 0

  metadata {
    name = local.eks_addon_clusterrole_name
  }

  rule {
    api_groups     = ["apiextensions.k8s.io"]
    resources      = ["customresourcedefinitions"]
    resource_names = ["opentelemetrycollectors.opentelemetry.io", "instrumentations.opentelemetry.io"]
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups     = [""]
    resources      = ["namespaces"]
    resource_names = [kubernetes_namespace_v1.adot[0].metadata[0].name]
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups     = ["rbac.authorization.k8s.io"]
    resources      = ["clusterroles"]
    resource_names = ["opentelemetry-operator-manager-role", "opentelemetry-operator-metrics-reader", "opentelemetry-operator-proxy-role"]
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups     = ["rbac.authorization.k8s.io"]
    resources      = ["clusterrolebindings"]
    resource_names = ["opentelemetry-operator-manager-rolebinding", "opentelemetry-operator-proxy-rolebinding"]
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups     = ["admissionregistration.k8s.io"]
    resources      = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
    resource_names = ["opentelemetry-operator-mutating-webhook-configuration", "opentelemetry-operator-validating-webhook-configuration"]
    verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["replicasets"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create", "get", "list", "update"]
  }
  rule {
    api_groups = ["opentelemetry.io"]
    resources  = ["opentelemetrycollectors"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = ["opentelemetry.io"]
    resources  = ["opentelemetrycollectors/finalizers"]
    verbs      = ["get", "patch", "update"]
  }
  rule {
    api_groups = ["opentelemetry.io"]
    resources  = ["opentelemetrycollectors/status"]
    verbs      = ["get", "patch", "update"]
  }
  rule {
    api_groups = ["opentelemetry.io"]
    resources  = ["instrumentations"]
    verbs      = ["get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = ["authentication.k8s.io"]
    resources  = ["tokenreviews"]
    verbs      = ["create"]
  }
  rule {
    api_groups = ["authorization.k8s.io"]
    resources  = ["subjectaccessreviews"]
    verbs      = ["create"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["get"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes/proxy"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "adot" {
  count = var.enable_amazon_eks_adot ? 1 : 0

  metadata {
    name = local.eks_addon_clusterrole_name
  }
  subject {
    kind      = "User"
    name      = local.eks_addon_role_name
    api_group = "rbac.authorization.k8s.io"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.eks_addon_clusterrole_name
  }

}


module "helm_addon" {
  source = "../helm-addon"
  count  = var.enable_opentelemetry_operator ? 1 : 0

  helm_config   = local.helm_config
  addon_context = var.addon_context

  depends_on = [module.cert_manager]
}
