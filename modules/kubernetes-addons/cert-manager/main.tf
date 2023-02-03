module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  set_values        = local.set_values
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "helm_release" "cert_manager_ca" {
  count     = var.manage_via_gitops ? 0 : 1
  name      = "cert-manager-ca"
  chart     = "${path.module}/cert-manager-ca"
  version   = "0.2.0"
  namespace = local.helm_config["namespace"]

  depends_on = [module.helm_addon]
}

resource "helm_release" "cert_manager_letsencrypt" {
  count     = var.manage_via_gitops || !var.install_letsencrypt_issuers ? 0 : 1
  name      = "cert-manager-letsencrypt"
  chart     = "${path.module}/cert-manager-letsencrypt"
  version   = "0.1.0"
  namespace = local.helm_config["namespace"]

  set {
    name  = "email"
    value = var.letsencrypt_email
    type  = "string"
  }

  set {
    name  = "dnsZones"
    value = "{${join(",", toset(var.domain_names))}}"
    type  = "string"
  }

  depends_on = [module.helm_addon]
}

resource "aws_iam_policy" "cert_manager" {
  description = "cert-manager IAM policy."
  name        = "${var.addon_context.eks_cluster_id}-${local.helm_config["name"]}-irsa"
  path        = var.addon_context.irsa_iam_role_path
  policy      = data.aws_iam_policy_document.cert_manager_iam_policy_document.json
  tags        = var.addon_context.tags
}
