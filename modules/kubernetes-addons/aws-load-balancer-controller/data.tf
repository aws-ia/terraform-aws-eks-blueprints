data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "aws_lb" {
  statement {
    sid       = "AllowCreateServiceLinkedRole"
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.${data.aws_partition.current.dns_suffix}"]
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
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/app/*/*",
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/net/*/*",
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:targetgroup/*/*",
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
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:targetgroup/*/*",
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
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener/app/*/*/*",
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener/net/*/*/*",
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
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener-rule/app/*/*/*/*",
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener-rule/net/*/*/*/*",
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
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/app/*/*",
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/net/*/*",
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener/app/*/*/*",
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener/net/*/*/*",
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener-rule/app/*/*/*/*",
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:listener-rule/net/*/*/*/*",
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:targetgroup/*/*",
    ]

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
    ]
  }

  statement {
    sid       = "AllowManageTargets"
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:targetgroup/*/*"]

    actions = [
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:RegisterTargets"
    ]
  }

  statement {
    sid    = "AllowGetCertificates"
    effect = "Allow"
    resources = [
      "arn:${data.aws_partition.current.partition}:acm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
      "arn:${data.aws_partition.current.partition}:acm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:certificate/*"
    ]

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates"
    ]
  }

  statement {
    sid       = "AllowDescribeCognitoIdp"
    effect    = "Allow"
    resources = ["arn:${data.aws_partition.current.partition}:cognito-idp:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:userpool/*"]

    actions = ["cognito-idp:DescribeUserPoolClient"]
  }

  statement {
    sid    = "AllowGetServerCertificates"
    effect = "Allow"
    resources = [
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:*",
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:server-certificate/*"
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
      "arn:${data.aws_partition.current.partition}:shield::${data.aws_caller_identity.current.account_id}:*",
      "arn:${data.aws_partition.current.partition}:shield::${data.aws_caller_identity.current.account_id}:protection/*"
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
      "arn:${data.aws_partition.current.partition}:elasticloadbalancing:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:loadbalancer/app/*/*",
      "arn:${data.aws_partition.current.partition}:apigateway:${data.aws_region.current.name}::/restapis/*/stages/*",
      "arn:${data.aws_partition.current.partition}:appsync:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:apis/*",
      "arn:${data.aws_partition.current.partition}:cognito-idp:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:userpool/*",
      "arn:${data.aws_partition.current.partition}:wafv2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
      "arn:${data.aws_partition.current.partition}:wafv2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/webacl/*/*",
      "arn:${data.aws_partition.current.partition}:waf-regional:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
      "arn:${data.aws_partition.current.partition}:waf-regional:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:webacl/*"
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
    resources = ["arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:security-group/*"]

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
      "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:security-group/*",
      "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:vpc/*",
    ]
    actions = ["ec2:CreateSecurityGroup"]
  }
}