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
      "autoscaling:CompleteLifecycleAction",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstances",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
    ]
    resources = ["*"]
  }
}
