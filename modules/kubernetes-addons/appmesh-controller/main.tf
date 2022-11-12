locals {
  name      = try(var.helm_config.name, "appmesh-controller")
  namespace = try(var.helm_config.namespace, "appmesh-system")

  partition  = data.aws_partition.current.partition
  dns_suffix = data.aws_partition.current.dns_suffix
}

data "aws_partition" "current" {}

module "helm_addon" {
  source = "../helm-addon"

  helm_config = merge(
    {
      name        = local.name
      chart       = local.name
      repository  = "https://aws.github.io/eks-charts"
      version     = "1.7.0"
      namespace   = local.namespace
      description = "AWS App Mesh Helm Chart"
    },
    var.helm_config
  )

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.name
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]

  irsa_config = {
    create_kubernetes_namespace       = true
    kubernetes_namespace              = local.namespace
    create_kubernetes_service_account = true
    kubernetes_service_account        = local.name
    irsa_iam_policies                 = concat([aws_iam_policy.this.arn], var.irsa_policies)
  }

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "this" {
  name        = "${var.addon_context.eks_cluster_id}-appmesh"
  description = "IAM Policy for App Mesh"
  policy      = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    sid       = "appmesh"
    effect    = "Allow"
    resources = ["*"]

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
    resources = ["arn:${local.partition}:iam::*:role/aws-service-role/appmesh.${local.dns_suffix}/AWSServiceRoleForAppMesh"]
    actions   = ["iam:CreateServiceLinkedRole"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["appmesh.${local.dns_suffix}"]
    }
  }

  statement {
    sid       = "ACMAccess"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "acm-pca:DescribeCertificateAuthority",
      "acm-pca:ListCertificateAuthorities"
    ]
  }

  statement {
    sid       = "ServiceDiscovery"
    effect    = "Allow"
    resources = ["*"]
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
      "servicediscovery:GetOperation",
      "route53:GetHealthCheck",
      "route53:CreateHealthCheck",
      "route53:UpdateHealthCheck",
      "route53:ChangeResourceRecordSets",
      "route53:DeleteHealthCheck"
    ]
  }
}
