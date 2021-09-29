data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

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

