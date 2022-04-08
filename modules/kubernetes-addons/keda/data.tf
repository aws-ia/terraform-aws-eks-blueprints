data "aws_iam_policy_document" "keda_irsa" {
  statement {
    effect = "Allow"

    resources = [
      "arn:${var.addon_context.aws_partition_id}:cloudwatch:*:${var.addon_context.aws_caller_identity_account_id}:metric-stream/*",
      "arn:${var.addon_context.aws_partition_id}:sqs:*:${var.addon_context.aws_caller_identity_account_id}:*",
    ]

    actions = [
      "sqs:GetQueueUrl",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes",
      "sqs:ListQueueTags",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:GetDashboard",
      "cloudwatch:GetInsightRuleReport",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetMetricStream",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudwatch:DescribeInsightRules",
      "sqs:ListQueues",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetricStreams",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:ListDashboards",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricWidgetImage",
      "cloudwatch:ListMetrics",
      "cloudwatch:DescribeAnomalyDetectors",
    ]
  }
}
