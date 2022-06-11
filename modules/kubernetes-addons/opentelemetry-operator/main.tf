resource "aws_eks_addon" "example" {
  cluster_name      = var.addon_context.eks_cluster_id
  resolve_conflicts = "OVERWRITE"
  addon_name        = "adot"
  depends_on        = [kubectl_manifest.opentelemetry-prereq]
}

resource "kubectl_manifest" "opentelemetry-prereq" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  labels:
    control-plane: controller-manager
  name: opentelemetry-operator-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: eks:addon-manager-otel
rules:
  - apiGroups: ["apiextensions.k8s.io"]
    resources: ["customresourcedefinitions"]
    resourceNames: ["opentelemetrycollectors.opentelemetry.io","instrumentations.opentelemetry.io"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: [""]
    resources: ["namespaces"]
    resourceNames: ["opentelemetry-operator-system"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["rbac.authorization.k8s.io"]
    resources: ["clusterroles"]
    resourceNames: ["opentelemetry-operator-manager-role", "opentelemetry-operator-metrics-reader", "opentelemetry-operator-proxy-role"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["rbac.authorization.k8s.io"]
    resources: ["clusterrolebindings"]
    resourceNames: ["opentelemetry-operator-manager-rolebinding", "opentelemetry-operator-proxy-rolebinding"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["admissionregistration.k8s.io"]
    resources: ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
    resourceNames: ["opentelemetry-operator-mutating-webhook-configuration", "opentelemetry-operator-validating-webhook-configuration"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  # ---
  - nonResourceURLs: ["/metrics"]
    verbs: ["get"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "patch"]
  - apiGroups: [""]
    resources: ["namespaces"]
    verbs: ["list", "watch"]
  - apiGroups: [""]
    resources: ["serviceaccounts"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["apps"]
    resources: ["daemonsets"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["apps"]
    resources: ["replicasets"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["apps"]
    resources: ["statefulsets"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["create", "get", "list", "update"]
  - apiGroups: ["opentelemetry.io"]
    resources: ["opentelemetrycollectors"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["opentelemetry.io"]
    resources: ["opentelemetrycollectors/finalizers"]
    verbs: ["get", "patch", "update"]
  - apiGroups: ["opentelemetry.io"]
    resources: ["opentelemetrycollectors/status"]
    verbs: ["get", "patch", "update"]
  - apiGroups: ["opentelemetry.io"]
    resources: ["instrumentations"]
    verbs: ["get", "list", "patch", "update", "watch"]
  - apiGroups: ["authentication.k8s.io"]
    resources: ["tokenreviews"]
    verbs: ["create"]
  - apiGroups: ["authorization.k8s.io"]
    resources: ["subjectaccessreviews"]
    verbs: ["create"]

---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: eks:addon-manager-otel
subjects:
- kind: User
  name: eks:addon-manager
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: eks:addon-manager-otel
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: eks:addon-manager
  namespace: opentelemetry-operator-system
rules:
  - apiGroups: [""]
    resources: ["serviceaccounts"]
    resourceNames: ["opentelemetry-operator-controller-manager"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["rbac.authorization.k8s.io"]
    resources: ["roles"]
    resourceNames: ["opentelemetry-operator-leader-election-role"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["rbac.authorization.k8s.io"]
    resources: ["rolebindings"]
    resourceNames: ["opentelemetry-operator-leader-election-rolebinding"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: [""]
    resources: ["services"]
    resourceNames: ["opentelemetry-operator-controller-manager-metrics-service", "opentelemetry-operator-webhook-service"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["apps"]
    resources: ["deployments"]
    resourceNames: ["opentelemetry-operator-controller-manager"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["cert-manager.io"]
    resources: ["certificates", "issuers"]
    resourceNames: ["opentelemetry-operator-serving-cert", "opentelemetry-operator-selfsigned-issuer"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  # ---
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: [""]
    resources: ["configmaps/status"]
    verbs: ["get", "update", "patch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "patch"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["list"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: eks:addon-manager
  namespace: opentelemetry-operator-system
subjects:
- kind: User
  name: eks:addon-manager
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: eks:addon-manager
  apiGroup: rbac.authorization.k8s.io
YAML
}

resource "kubernetes_namespace_v1" "prometheus" {
  metadata {
    name = local.helm_config["namespace"]
    labels = {
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
    }
  }
}
