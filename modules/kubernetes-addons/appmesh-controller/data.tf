data "aws_iam_policy_document" "this" {
  statement {
    sid       = "AllowAppMesh"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:appmesh:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:mesh/*"]

    actions = [
      "appmesh:ListVirtualRouters",
      "appmesh:ListVirtualServices",
      "appmesh:ListRoutes",
      "appmesh:ListGatewayRoutes",
      "appmesh:ListMeshes",
      "appmesh:ListVirtualNodes",
      "appmesh:ListVirtualGateways",
      "appmesh:DescribeMesh",
      "appmesh:DescribeVirtualRouter",
      "appmesh:DescribeRoute",
      "appmesh:DescribeVirtualNode",
      "appmesh:DescribeVirtualGateway",
      "appmesh:DescribeGatewayRoute",
      "appmesh:DescribeVirtualService",
      "appmesh:CreateMesh",
      "appmesh:CreateVirtualRouter",
      "appmesh:CreateVirtualGateway",
      "appmesh:CreateVirtualService",
      "appmesh:CreateGatewayRoute",
      "appmesh:CreateRoute",
      "appmesh:CreateVirtualNode",
      "appmesh:UpdateMesh",
      "appmesh:UpdateRoute",
      "appmesh:UpdateVirtualGateway",
      "appmesh:UpdateVirtualRouter",
      "appmesh:UpdateGatewayRoute",
      "appmesh:UpdateVirtualService",
      "appmesh:UpdateVirtualNode",
      "appmesh:DeleteMesh",
      "appmesh:DeleteRoute",
      "appmesh:DeleteVirtualRouter",
      "appmesh:DeleteGatewayRoute",
      "appmesh:DeleteVirtualService",
      "appmesh:DeleteVirtualNode",
      "appmesh:DeleteVirtualGateway"
    ]
  }

  statement {
    sid       = "CreateServiceLinkedRole"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:iam::${var.addon_context.aws_caller_identity_account_id}:role/aws-service-role/appmesh.${local.dns_suffix}/AWSServiceRoleForAppMesh"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["appmesh.${local.dns_suffix}"]
    }
  }

  statement {
    sid       = "AllowACMAccess"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:acm:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:certificate/*"]
    actions = [
      "acm:ListCertificates",
      "acm:DescribeCertificate",
    ]
  }

  statement {
    sid       = "AllowACMPCAAccess"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:acm-pca:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:certificate-authority/*"]
    actions = [
      "acm-pca:DescribeCertificateAuthority",
      "acm-pca:ListCertificateAuthorities"
    ]
  }

  statement {
    sid    = "AllowServiceDiscovery"
    effect = "Allow"
    resources = [
      "arn:${var.addon_context.aws_partition_id}:servicediscovery:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:namespace/*",
      "arn:${var.addon_context.aws_partition_id}:servicediscovery:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:service/*"
    ]
    actions = [
      "servicediscovery:CreateService",
      "servicediscovery:DeleteService",
      "servicediscovery:GetService",
      "servicediscovery:GetInstance",
      "servicediscovery:RegisterInstance",
      "servicediscovery:DeregisterInstance",
      "servicediscovery:ListInstances",
      "servicediscovery:ListNamespaces",
      "servicediscovery:ListServices",
      "servicediscovery:GetInstancesHealthStatus",
      "servicediscovery:UpdateInstanceCustomHealthStatus",
      "servicediscovery:GetOperation"
    ]
  }

  statement {
    sid    = "AllowRoute53"
    effect = "Allow"
    resources = [
    "arn:${var.addon_context.aws_partition_id}:route53:::*"]
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetHealthCheck",
      "route53:CreateHealthCheck",
      "route53:UpdateHealthCheck",
      "route53:DeleteHealthCheck"
    ]
  }
}
