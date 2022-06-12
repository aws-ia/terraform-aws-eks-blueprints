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

resource "aws_eks_addon" "adot" {
  cluster_name      = var.addon_context.eks_cluster_id
  resolve_conflicts = "OVERWRITE"
  addon_name        = "adot"
  depends_on        = [kubectl_manifest.adot, module.cert_manager]
}
