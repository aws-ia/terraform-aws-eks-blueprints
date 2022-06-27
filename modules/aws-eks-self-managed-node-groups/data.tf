data "aws_iam_policy_document" "self_managed_ng_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = [local.ec2_principal]
    }
  }
}

# Default AWS-provided EKS optimized AMIs
data "aws_ami" "predefined" {
  for_each    = local.predefined_ami_names
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [each.value]
  }
}

data "aws_iam_policy_document" "eks_windows_cni" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
    ]
  }
}
