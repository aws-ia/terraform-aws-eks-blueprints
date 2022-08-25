module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  set_values        = local.set_values
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context

  depends_on = [
    kubectl_manifest.karpenter_crd_provisioners,
    kubectl_manifest.karpenter_crd_awsnodetemplates,
  ]
}

resource "aws_iam_policy" "karpenter" {
  name        = "${var.addon_context.eks_cluster_id}-karpenter"
  description = "IAM Policy for Karpenter"
  policy      = data.aws_iam_policy_document.karpenter.json
}

## karpenter requires manual CRD updates https://karpenter.sh/preview/upgrade-guide/#custom-resource-definition-crd-upgrades

data "http" "karpenter_crd_provisioners" {
  url = "https://raw.githubusercontent.com/aws/karpenter/v${local.helm_config.version}/charts/karpenter/crds/karpenter.sh_provisioners.yaml"
}

resource "kubectl_manifest" "karpenter_crd_provisioners" {
  yaml_body = data.http.karpenter_crd_provisioners.response_body
}

data "http" "karpenter_crd_awsnodetemplates" {
  url = "https://raw.githubusercontent.com/aws/karpenter/v${local.helm_config.version}/charts/karpenter/crds/karpenter.k8s.aws_awsnodetemplates.yaml"
}

resource "kubectl_manifest" "karpenter_crd_awsnodetemplates" {
  yaml_body = data.http.karpenter_crd_awsnodetemplates.response_body
}
