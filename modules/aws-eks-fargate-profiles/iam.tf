
#----------------------------------------------------------
#IAM Policy for Fargate Fluentbit
#----------------------------------------------------------
resource "aws_iam_policy" "eks-fargate-logging-policy" {
  name        = "${var.eks_cluster_name}-${local.fargate_profiles["fargate_profile_name"]}"
  description = "Allow fargate profiles to writ logs to CW"

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

resource "aws_iam_role_policy_attachment" "fargate-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

resource "aws_iam_role_policy_attachment" "eks-fargate-logging-policy-attach" {
  policy_arn = aws_iam_policy.eks-fargate-logging-policy.arn
  role       = aws_iam_role.fargate.name
}

