data "aws_iam_policy_document" "aws_node_termination_handler_queue_policy_document" {
  statement {
    actions = [
      "sqs:SendMessage"
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com"
      ]
    }
    resources = [
      aws_sqs_queue.aws_node_termination_handler_queue.arn
    ]
  }
}

data "aws_iam_policy_document" "irsa_policy" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "autoscaling:CompleteLifecycleAction",
    ]
    resources = ["arn:${var.addon_context.aws_partition_id}:autoscaling:${var.addon_context.aws_region_name}:${var.addon_context.aws_caller_identity_account_id}:autoScalingGroup:*"]
  }

  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
    ]
    resources = [aws_sqs_queue.aws_node_termination_handler_queue.arn]
  }
}
