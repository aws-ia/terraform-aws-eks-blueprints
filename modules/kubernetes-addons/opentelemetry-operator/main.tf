module "cert_manager" {
  source        = "../cert-manager"
  addon_context = var.addon_context
}

resource "kubernetes_namespace_v1" "adot" {
  metadata {
    name = local.helm_config["namespace"]
    labels = {
      "app.kubernetes.io/managed-by" = "terraform-aws-eks-blueprints"
      "control-plane"                = "controller-manager"
    }
  }
}

data "kubectl_path_documents" "adot" {
  pattern = "${path.module}/manifests/*.yaml"
}

# official kubernetes_manifest issue
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest#before-you-use-this-resource
resource "kubectl_manifest" "adot" {
  for_each   = toset(data.kubectl_path_documents.adot.documents)
  yaml_body  = each.value
  depends_on = [kubernetes_namespace_v1.adot]
}

data "aws_eks_addon_version" "this" {
  addon_name = local.name
  # Need to allow both config routes - for managed and self-managed configs
  kubernetes_version = try(var.addon_config.kubernetes_version, var.helm_config.kubernetes_version)
  most_recent        = try(var.addon_config.most_recent, var.helm_config.most_recent, true)
}

resource "aws_eks_addon" "adot" {
  cluster_name             = var.addon_context.eks_cluster_id
  addon_name               = local.name
  addon_version            = try(var.addon_config.addon_version, data.aws_eks_addon_version.this.version)
  resolve_conflicts        = try(var.addon_config.resolve_conflicts, "OVERWRITE")
  service_account_role_arn = try(var.addon_config.service_account_role_arn, null)
  preserve                 = try(var.addon_config.preserve, true)

  tags = merge(
    var.addon_context.tags,
    try(var.addon_config.tags, {})
  )
  depends_on = [kubectl_manifest.adot, module.cert_manager]
}
