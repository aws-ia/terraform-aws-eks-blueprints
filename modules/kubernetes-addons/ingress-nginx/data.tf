data "aws_iam_policy_document" "this" {
  statement {
    sid       = "ReadOnly"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags"
    ]
  }

  statement {
    sid       = "ListenerRulesWrite"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule",
    ]
  }

  statement {
    sid    = "ConditionalWrite"
    effect = "Allow"

    resources = [
      "arn:aws:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:loadbalancer/app/*/*"
    ]

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:DeleteTargetGroup"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/service-name"
      values   = ["${local.namespace}/ingress-nginx-controller"]
    }
  }

  statement {
    sid    = "ConditionalCreate"
    effect = "Allow"

    resources = [
      "arn:aws:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:loadbalancer/app/*/*"
    ]

    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/service-name"
      values   = ["${local.namespace}/ingress-nginx-controller"]
    }
  }
}
