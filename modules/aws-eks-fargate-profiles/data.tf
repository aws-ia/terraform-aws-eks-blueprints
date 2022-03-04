data "aws_iam_policy_document" "fargate_assume_role_policy" {
  statement {
    sid = "EKSFargateAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "cwlogs" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
  }
}
