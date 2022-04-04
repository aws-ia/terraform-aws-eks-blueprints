# Codepipeline role

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.project_name}-codepipeline-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  path               = "/"
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.project_name}-codepipeline-policy"
  description = "Policy to allow codepipeline to execute"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        },
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ecr:GetAuthorizationToken"
          ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:List*",
                "iam:Tag*",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy",
                "autoscaling:*",
                "iam:AddRoleToInstanceProfile",
                "codebuild:BatchGetBuilds",
                "iam:DetachRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:DeleteOpenIDConnectProvider",
                "codecommit:UpdatePullRequestApprovalState",
                "iam:GetRole",
                "codecommit:PostCommentForPullRequest",
                "iam:Untag*",
                "iam:DeleteRole",
                "cloudformation:*",
                "codecommit:GetUploadArchiveStatus",
                "ec2:*",
                "codecommit:List*",
                "codebuild:StartBuild",
                "iam:GetOpenIDConnectProvider",
                "codecommit:Describe*",
                "eks:*",
                "iam:GetRolePolicy",
                "codebuild:BatchPutTestCases",
                "iam:CreateInstanceProfile",
                "codecommit:Get*",
                "iam:TagRole",
                "codecommit:BatchGet*",
                "iam:ListInstanceProfilesForRole",
                "codebuild:CreateReport",
                "iam:PassRole",
                "iam:Get*",
                "codebuild:UpdateReport",
                "iam:DeleteRolePolicy",
                "iam:DeleteInstanceProfile",
                "codecommit:UploadArchive",
                "iam:GetInstanceProfile",
                "codecommit:GitPull",
                "iam:ListInstanceProfiles",
                "codecommit:CancelUploadArchive",
                "iam:CreateOpenIDConnectProvider",
                "iam:CreatePolicy",
                "codebuild:CreateReportGroup",
                "codecommit:EvaluatePullRequestApprovalRules",
                "codecommit:GetBranch",
                "ssm:*",
                "codecommit:BatchDescribe*",
                "iam:*",
                "lambda:*",
                "ec2:*",
                "codecommit:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning",
                "s3:PutObjectAcl",
                "s3:PutObject"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline-attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}
