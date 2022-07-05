
data "aws_secretsmanager_secret" "admin_password" {
  count = var.grafana_admin_password_secret_name == "" ? 0 : 1
  name  = var.grafana_admin_password_secret_name
}

data "aws_secretsmanager_secret_version" "admin_password_version" {
  count     = var.grafana_admin_password_secret_name == "" ? 0 : 1
  secret_id = data.aws_secretsmanager_secret.admin_password[0].id
}

data "aws_iam_policy_document" "this" {
  statement {
    sid       = "AllowReadingMetricsFromCloudWatch"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:cloudwatch:${var.addon_context.aws_caller_identity_account_id}:*:*"]

    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetInsightRuleReport",
    ]
  }

  statement {
    sid       = "AllowReadingLogsFromCloudWatch"
    effect    = "Allow"
    resources = ["arn:${var.addon_context.aws_partition_id}:logs:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:log-group:*:log-stream:*"]

    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents",
    ]
  }

  statement {
    sid       = "AllowReadingTagsInstancesRegionsFromEC2"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
    ]
  }

  statement {
    sid       = "AllowReadingResourcesForTags"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["tag:GetResources"]
  }
}
