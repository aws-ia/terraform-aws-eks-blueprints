#----------------------------------------------------------
#IAM Policy for Fargate Fluentbit
#----------------------------------------------------------
resource "aws_iam_policy" "fargate" {
  name        = "${var.eks_cluster_name}-${local.fargate_profiles["fargate_profile_name"]}"
  description = "Allow fargate profiles to write logs to CloudWatch"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": [
			"logs:CreateLogStream",
			"logs:CreateLogGroup",
			"logs:DescribeLogStreams",
			"logs:PutLogEvents"
		],
		"Resource": "*"
	}]
}
EOF
}

resource "aws_iam_role" "fargate" {
  name                  = "${var.eks_cluster_name}-${local.fargate_profiles["fargate_profile_name"]}"
  assume_role_policy    = data.aws_iam_policy_document.fargate_assume_role_policy.json
  force_detach_policies = true
  tags                  = var.tags

}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

resource "aws_iam_role_policy_attachment" "fargate_policy" {
  policy_arn = aws_iam_policy.fargate.arn
  role       = aws_iam_role.fargate.name
}
