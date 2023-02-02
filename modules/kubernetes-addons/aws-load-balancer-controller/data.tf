data "aws_iam_policy_document" "aws_lb" {
  statement {
    sid       = "AllowCreateServiceLinkedRole"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:iam::${var.addon_context.aws_caller_identity_account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowDescribeElbTags"
    effect    = "Allow"
    resources = ["*"] #tfsec:ignore:aws-iam-no-policy-wildcards

    actions = ["elasticloadbalancing:DescribeTags"]
  }

  statement {
    sid       = "AllowGetResources"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeCoipPools",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeVpcs",
      "ec2:GetCoipPoolUsage",
    ]
  }

  statement {
    sid    = "AllowManageElbs"
    effect = "Allow"

    resources = [
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:loadbalancer/app/*/*",
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:loadbalancer/net/*/*",
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:targetgroup/*/*",
    ]

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
    ]
  }

  statement {
    sid    = "AllowManageTargetGroup"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:targetgroup/*/*",
    ]

    actions = [
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
    ]
  }

  statement {
    sid    = "AllowManageListeners"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:listener/app/*/*/*",
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:listener/net/*/*/*",
    ]

    actions = [
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates"
    ]
  }

  statement {
    sid    = "AllowManageRules"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:listener-rule/app/*/*/*/*",
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:listener-rule/net/*/*/*/*",
    ]

    actions = [
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:ModifyRule"
    ]
  }

  statement {
    sid    = "AllowManageResourceTags"
    effect = "Allow"

    resources = [
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:loadbalancer/app/*/*",
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:loadbalancer/net/*/*",
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:listener/app/*/*/*",
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:listener/net/*/*/*",
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:listener-rule/app/*/*/*/*",
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:listener-rule/net/*/*/*/*",
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:targetgroup/*/*",
    ]

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
    ]
  }

  statement {
    sid       = "AllowManageTargets"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:targetgroup/*/*"]

    actions = [
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:RegisterTargets"
    ]
  }

  statement {
    sid    = "AllowGetCertificates"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:acm:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:*",
      "arn:${var.addon_context.aws_partition_id}:acm:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:certificate/*"
    ]

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates"
    ]
  }

  statement {
    sid       = "AllowDescribeCognitoIdp"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:cognito-idp:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:userpool/*"]

    actions = ["cognito-idp:DescribeUserPoolClient"]
  }

  statement {
    sid    = "AllowGetServerCertificates"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:iam::${var.addon_context.aws_caller_identity_account_id}:*",
      "arn:${var.addon_context.aws_partition_id}:iam::${var.addon_context.aws_caller_identity_account_id}:server-certificate/*"
    ]

    actions = [
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
    ]
  }

  statement {
    sid    = "AllowShield"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:shield::${var.addon_context.aws_caller_identity_account_id}:*",
      "arn:${var.addon_context.aws_partition_id}:shield::${var.addon_context.aws_caller_identity_account_id}:protection/*"
    ]

    actions = [
      "shield:CreateProtection",
      "shield:DeleteProtection",
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
    ]
  }

  statement {
    sid    = "AllowManageWebAcl"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:elasticloadbalancing:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:loadbalancer/app/*/*",
      "arn:${var.addon_context.aws_partition_id}:apigateway:${var.addon_context.aws_region_name}::/restapis/*/stages/*",
      "arn:${var.addon_context.aws_partition_id}:appsync:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:apis/*",
      "arn:${var.addon_context.aws_partition_id}:cognito-idp:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:userpool/*",
      "arn:${var.addon_context.aws_partition_id}:wafv2:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:*",
      "arn:${var.addon_context.aws_partition_id}:wafv2:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:*/webacl/*/*",
      "arn:${var.addon_context.aws_partition_id}:waf-regional:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:*",
      "arn:${var.addon_context.aws_partition_id}:waf-regional:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:webacl/*"
    ]

    actions = [
      "elasticloadbalancing:SetWebAcl",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
    ]
  }

  statement {
    sid       = "AllowManageSecurityGroups"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:ec2:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:security-group/*"]

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]
  }

  statement {
    sid    = "AllowCreateSecurityGroups"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:ec2:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:security-group/*",
      "arn:${var.addon_context.aws_partition_id}:ec2:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:vpc/*",
    ]
    actions = ["ec2:CreateSecurityGroup"]
  }
}
