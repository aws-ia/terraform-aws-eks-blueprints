data "aws_iam_policy_document" "keda_irsa" {
  statement {
    effect = "Allow"

    resources = [
      "arn:${var.addon_context.aws_partition_id}:cloudwatch:*:${var.addon_context.aws_caller_identity_account_id}:metric-stream/*",
      "arn:${var.addon_context.aws_partition_id}:sqs:*:${var.addon_context.aws_caller_identity_account_id}:*",
    ]

    actions = [
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetDashboard",
      "cloudwatch:GetInsightRuleReport",
      "cloudwatch:GetMetricStream",
      "cloudwatch:ListTagsForResource",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ListQueueTags",
      "sqs:ReceiveMessage",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAnomalyDetectors",
      "cloudwatch:DescribeInsightRules",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricWidgetImage",
      "cloudwatch:ListDashboards",
      "cloudwatch:ListMetrics",
      "cloudwatch:ListMetricStreams",
      "sqs:ListQueues",
    ]
  }
}
