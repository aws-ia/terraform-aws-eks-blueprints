/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

data "aws_region" "current" {}

#-------------------------------------------------------------------------------------------------
#IAM Policy for Fargate Fluentbit
#--------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "eks-fargate-logging-policy" {
  name        = "${var.eks_cluster_id}-fargate-log-policy"
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

resource "aws_iam_role_policy_attachment" "fargate_profile_role" {
  role       = var.fargate_iam_role
  policy_arn = aws_iam_policy.eks-fargate-logging-policy.arn
}


resource "kubernetes_namespace" "aws_observability" {
  metadata {
    name = "aws-observability"

    labels = {
      aws-observability = "enabled"
    }
  }
}

resource "kubernetes_config_map" "aws_logging" {
  metadata {
    name      = "aws-logging"
    namespace = kubernetes_namespace.aws_observability.id
  }

  data = {
    "output.conf" = "[OUTPUT]\n    Name cloudwatch_logs\n    Match   *\n    region ${data.aws_region.current.id}\n    log_group_name /aws/eks/${var.eks_cluster_id}/fluent-bit-cloudwatch\n    log_stream_prefix from-fluent-bit-\n    auto_create_group On\n"
  }
}

