locals {
  name            = try(var.helm_config.name, "external-dns")
  service_account = try(var.helm_config.service_account, "${local.name}-sa")

  argocd_gitops_config = merge(
    {
      enable             = true
      serviceAccountName = local.service_account
    },
    var.helm_config
  )
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/bitnami/charts/blob/main/bitnami/external-dns/Chart.yaml
  helm_config = merge(
    {
      description = "ExternalDNS Helm Chart"
      name        = local.name
      chart       = local.name
      repository  = "https://charts.bitnami.com/bitnami"
      version     = "6.11.2"
      namespace   = local.name
      values = [
        <<-EOT
          provider: aws
          aws:
            region: ${var.addon_context.aws_region_name}
        EOT
      ]
    },
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
        value = false
      }
    ],
    try(var.helm_config.set_values, [])
  )

  irsa_config = {
    create_kubernetes_namespace         = try(var.helm_config.create_namespace, true)
    kubernetes_namespace                = try(var.helm_config.namespace, local.name)
    create_kubernetes_service_account   = true
    create_service_account_secret_token = try(var.helm_config["create_service_account_secret_token"], false)
    kubernetes_service_account          = local.service_account
    irsa_iam_policies                   = concat([aws_iam_policy.external_dns.arn], var.irsa_policies)
  }

  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
}

#------------------------------------
# IAM Policy
#------------------------------------

resource "aws_iam_policy" "external_dns" {
  description = "External DNS IAM policy."
  name        = "${var.addon_context.eks_cluster_id}-${local.name}-irsa"
  path        = var.addon_context.irsa_iam_role_path
  policy      = data.aws_iam_policy_document.external_dns_iam_policy_document.json
  tags        = var.addon_context.tags
}

# TODO - remove at next breaking change
data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = var.private_zone
}

data "aws_iam_policy_document" "external_dns_iam_policy_document" {
  statement {
    effect = "Allow"
    resources = distinct(concat(
      [data.aws_route53_zone.selected.arn],
      var.route53_zone_arns
    ))
    actions = ["route53:ChangeResourceRecordSets"]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
  }
}
