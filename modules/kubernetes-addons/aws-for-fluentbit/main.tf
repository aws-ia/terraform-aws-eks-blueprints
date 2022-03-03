resource "helm_release" "aws_for_fluent_bit" {
  count                      = var.manage_via_gitops ? 0 : 1
  name                       = local.helm_config["name"]
  repository                 = local.helm_config["repository"]
  chart                      = local.helm_config["chart"]
  version                    = local.helm_config["version"]
  namespace                  = local.helm_config["namespace"]
  timeout                    = local.helm_config["timeout"]
  values                     = local.helm_config["values"]
  create_namespace           = local.helm_config["create_namespace"]
  lint                       = local.helm_config["lint"]
  description                = local.helm_config["description"]
  repository_key_file        = local.helm_config["repository_key_file"]
  repository_cert_file       = local.helm_config["repository_cert_file"]
  repository_ca_file         = local.helm_config["repository_ca_file"]
  repository_username        = local.helm_config["repository_username"]
  repository_password        = local.helm_config["repository_password"]
  verify                     = local.helm_config["verify"]
  keyring                    = local.helm_config["keyring"]
  disable_webhooks           = local.helm_config["disable_webhooks"]
  reuse_values               = local.helm_config["reuse_values"]
  reset_values               = local.helm_config["reset_values"]
  force_update               = local.helm_config["force_update"]
  recreate_pods              = local.helm_config["recreate_pods"]
  cleanup_on_fail            = local.helm_config["cleanup_on_fail"]
  max_history                = local.helm_config["max_history"]
  atomic                     = local.helm_config["atomic"]
  skip_crds                  = local.helm_config["skip_crds"]
  render_subchart_notes      = local.helm_config["render_subchart_notes"]
  disable_openapi_validation = local.helm_config["disable_openapi_validation"]
  wait                       = local.helm_config["wait"]
  wait_for_jobs              = local.helm_config["wait_for_jobs"]
  dependency_update          = local.helm_config["dependency_update"]
  replace                    = local.helm_config["replace"]

  postrender {
    binary_path = local.helm_config["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = local.helm_config["set"] != null ? distinct(concat(local.override_set_values, local.helm_config["set"])) : local.helm_config["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = local.helm_config["set_sensitive"] == null ? [] : local.helm_config["set_sensitive"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  depends_on = [aws_cloudwatch_log_group.aws_for_fluent_bit, module.irsa]
}

resource "aws_cloudwatch_log_group" "aws_for_fluent_bit" {
  name              = local.log_group_name
  retention_in_days = var.cw_log_group_retention
  kms_key_id        = var.cw_log_group_kms_key_arn == null ? module.kms[0].key_arn : var.cw_log_group_kms_key_arn
  tags              = var.addon_context.tags
}

resource "aws_iam_policy" "aws_for_fluent_bit" {
  name        = "${var.addon_context.eks_cluster_id}-fluentbit"
  description = "IAM Policy for AWS for FluentBit"
  policy      = data.aws_iam_policy_document.irsa.json
  tags        = var.addon_context.tags
}

module "irsa" {
  source                     = "../../../modules/irsa"
  kubernetes_namespace       = local.helm_config["namespace"]
  kubernetes_service_account = local.service_account_name
  irsa_iam_policies          = concat([aws_iam_policy.aws_for_fluent_bit.arn], var.irsa_policies)
  addon_context              = var.addon_context
}

module "kms" {
  count       = var.cw_log_group_kms_key_arn == null ? 1 : 0
  source      = "../../../modules/aws-kms"
  description = "EKS Workers FluentBit CloudWatch Log group KMS Key"
  alias       = "alias/${var.addon_context.eks_cluster_id}-cw-fluent-bit"
  policy      = data.aws_iam_policy_document.kms.json
  tags        = var.addon_context.tags
}
