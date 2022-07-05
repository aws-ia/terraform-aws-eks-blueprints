data "aws_iam_policy_document" "managed_ng_assume_role_policy" {
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

data "external" "get_max_pod_number" {
  program = ["bash", "${path.module}/scripts/get-max-pod.sh", local.node_instance_type]
}