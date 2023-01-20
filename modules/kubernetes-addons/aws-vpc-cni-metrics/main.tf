locals {
  name            = "cni-metrics-helper"
  service_account = try(var.helm_config.service_account, local.name)
  version         = var.addon_version

  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://aws.github.io/eks-charts"
    version          = "0.1.15"
    namespace        = "kube-system"
    create_namespace = false
    values           = null
    description      = "aws-load-balancer-controller Helm Chart for ingress resources"
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = concat(
    [
      {
        name  = "serviceAccount.name"
        value = local.service_account
      },
      {
        name  = "serviceAccount.create"
        value = true
      },
      {
        name  = "env.AWS_VPC_K8S_CNI_LOGLEVEL"
        value = "INFO"
      },
      {
        name  = "image.override"
        value = "${var.addon_context.default_repository}/cni-metrics-helper:${local.version}"
      }
    ],
    try(var.helm_config.set_values, [])
  )

}

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

data "aws_iam_policy_document" "aws_vpc_cni_metrics" {
  statement {
    sid = "CNIMetrics"
    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
}
