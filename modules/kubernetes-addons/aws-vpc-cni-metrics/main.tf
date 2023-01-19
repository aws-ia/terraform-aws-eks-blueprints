module "vpc_cni_metrics_addon" {
  source = "github.com/aws-ia/terraform-aws-eks-addon?ref=v1.0.0"

  name             = local.name
  chart            = local.name
  repository       = local.helm_config["repository"]
  chart_version    = local.helm_config["version"]
  namespace        = local.helm_config["namespace"]
  create_namespace = local.helm_config["create_namespace"]
  values           = local.helm_config["values"]
  set              = local.set_values
  description      = "A Helm chart for the AWS VPC CNI Metrics Helper"

  set_irsa_name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  # # Equivalent to the following but the ARN is only known internally to the module
  # set = [{
  #   name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  #   value = iam_role_arn.this[0].arn
  # }]

  # IAM role for service account (IRSA)
  create_role = true
  role_policy_arns = {
    cni_metrics = aws_iam_policy.aws_vpc_cni_metrics.arn
  }

  oidc_providers = {
    this = {
      provider_arn = var.addon_context.eks_oidc_provider_arn
      # namespace is inherited from chart
      service_account = local.service_account
    }
  }

  tags = var.addon_context.tags
}

resource "aws_iam_policy" "aws_vpc_cni_metrics" {
  name        = "${var.addon_context.eks_cluster_id}-cni-metrics"
  description = "IAM policy for EKS CNI Metrics helper"
  path        = "/"
  policy      = data.aws_iam_policy_document.aws_vpc_cni_metrics.json

  tags = var.addon_context.tags
}