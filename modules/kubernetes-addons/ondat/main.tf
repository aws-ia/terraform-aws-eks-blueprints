locals {
  name                 = "ondat"
  service_account_name = "storageos-operator"

  ondat_etcd_endpoints = length(var.etcd_endpoints) == 0 ? "storageos-etcd.storageos-etcd:2379" : join(",", var.etcd_endpoints)

  argocd_gitops_config = {
    enable                             = true
    etcdClusterCreate                  = length(var.etcd_endpoints) == 0
    serviceAccountName                 = local.service_account_name
    clusterSecretRefName               = "storageos-api"
    clusterAdminUsername               = "storageos"
    clusterAdminPassword               = "storageos"
    clusterKvBackendAddress            = local.ondat_etcd_endpoints
    clusterKvBackendTLSSecretName      = length(kubernetes_secret.etcd) > 0 ? kubernetes_secret.etcd[0].metadata[0].name : "storageos-etcd-secret"
    clusterKvBackendTLSSecretNamespace = length(kubernetes_secret.etcd) > 0 ? kubernetes_secret.etcd[0].metadata[0].namespace : "storageos"
    clusterNodeSelectorTermKey         = "storageos-node"
    clusterNodeSelectorTermValue       = "1"
    etcdNodeSelectorTermKey            = "storageos-etcd"
    etcdNodeSelectorTermValue          = "1"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml",
    {
      ondat_service_account_name   = local.service_account_name,
      ondat_nodeselectorterm_key   = "storageos-node"
      ondat_nodeselectorterm_value = "1"
      etcd_nodeselectorterm_key    = "storageos-etcd"
      etcd_nodeselectorterm_value  = "1"
      ondat_admin_username         = "storageos",
      ondat_admin_password         = "storageos",
      ondat_credential_secret_name = "storageos-api",
      etcd_address                 = local.ondat_etcd_endpoints,
    },
  )]
}

module "helm_addon" {
  source = "../helm-addon"

  manage_via_gitops = var.manage_via_gitops

  helm_config = merge(
    {
      name             = local.name
      chart            = "ondat"
      repository       = "https://ondat.github.io/charts"
      version          = "0.2.5"
      namespace        = kubernetes_namespace.ondat.metadata[0].name
      timeout          = "1500"
      create_namespace = false
      values           = local.default_helm_values
      description      = "Ondat Helm Chart for storage"
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "ondat-operator.serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "ondat-operator.cluster.create"
      value = var.create_cluster
    },
    {
      name  = "ondat-operator.cluster.secretRefName"
      value = "storageos-api"
    },
    {
      name  = "ondat-operator.cluster.kvBackend.address"
      value = local.ondat_etcd_endpoints
    },
    {
      name  = "ondat-operator.cluster.kvBackend.tlsSecretName"
      value = length(kubernetes_secret.etcd) > 0 ? kubernetes_secret.etcd[0].metadata[0].name : "storageos-etcd-secret"
    },
    {
      name  = "ondat-operator.cluster.kvBackend.tlsSecretNamespace"
      value = length(kubernetes_secret.etcd) > 0 ? kubernetes_secret.etcd[0].metadata[0].namespace : "storageos"
    },
    {
      name  = "etcd-cluster-operator.cluster.create"
      value = length(var.etcd_endpoints) == 0
    },
  ]

  set_sensitive_values = [
    {
      name  = "cluster.admin.username",
      value = var.admin_username
    },
    {
      name  = "cluster.admin.password",
      value = var.admin_password
    },
  ]

  irsa_config = {
    create_kubernetes_namespace = false
    kubernetes_namespace        = kubernetes_namespace.ondat.metadata[0].name

    create_kubernetes_service_account = true
    kubernetes_service_account        = local.service_account_name

    iam_role_path                 = "/"
    tags                          = var.addon_context.tags
    eks_cluster_id                = var.addon_context.eks_cluster_id
    irsa_iam_policies             = var.irsa_policies
    irsa_iam_permissions_boundary = var.irsa_permissions_boundary
  }

  addon_context = var.addon_context
}

resource "kubernetes_namespace" "ondat" {
  metadata {
    name = "ondat"
    labels = {
      app = local.name
    }
  }
}

################################################################################
# Secrets
################################################################################

resource "kubernetes_namespace" "storageos" {
  count = length(var.etcd_endpoints) == 0 ? 0 : 1

  metadata {
    name = "storageos"
    labels = {
      app = local.name
    }
  }
}

resource "kubernetes_secret" "etcd" {
  count = length(var.etcd_endpoints) == 0 ? 0 : 1

  metadata {
    name      = "storageos-etcd"
    namespace = kubernetes_namespace.storageos[0].metadata[0].name
    labels = {
      app = local.name
    }
  }

  data = {
    "etcd-client-ca.crt" = var.etcd_ca
    "etcd-client.crt"    = var.etcd_cert
    "etcd-client.key"    = var.etcd_key
  }

  type = "kubernetes.io/storageos"
}

################################################################################
# Storage Class
################################################################################

resource "kubernetes_storage_class" "etcd" {
  count = length(var.etcd_endpoints) == 0 ? 1 : 0

  metadata {
    name = "etcd"
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type = "gp3"
  }
}
