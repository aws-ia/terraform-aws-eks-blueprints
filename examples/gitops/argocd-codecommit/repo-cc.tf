resource "aws_codecommit_repository" "workloads_repo_cc" {
  repository_name = "eks-blueprints-workloads-cc"
  default_branch  = "main"
}

resource "aws_iam_user" "argocd_user" {
  name = "argocd-cc"
}

resource "aws_iam_service_specific_credential" "argocd_codecommit_credential" {
  service_name = "codecommit.amazonaws.com"
  user_name    = aws_iam_user.argocd_user.name
}

resource "aws_iam_user_policy" "argocd_user_codecommit_ro" {
  name = "argocd-user-codecommit-ro"
  user = aws_iam_user.argocd_user.name

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "codecommit:GitPull",
        Resource : aws_codecommit_repository.workloads_repo_cc.arn
      }
    ]
  })
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({

    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "lambda.amazonaws.com"
        },
        Effect : "Allow"
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source_dir  = "${path.module}/lambda"
}

resource "aws_lambda_function" "lambda_webhook" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = join("-", [aws_codecommit_repository.workloads_repo_cc.repository_name, "webhook"])
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
}

resource "aws_codecommit_trigger" "workloads_repo_cc_trigger" {
  repository_name = aws_codecommit_repository.workloads_repo_cc.repository_name
  trigger {
    name            = "all"
    events          = ["all"]
    custom_data     = var.argocd_url
    destination_arn = aws_lambda_function.lambda_webhook.arn
  }

  depends_on = [
    module.eks_blueprints
  ]
}

resource "kubectl_manifest" "repo_creds_platform_https" {
  yaml_body = <<-EOF
    apiVersion: v1
    kind: Secret
    metadata:
      name: repo-creds-platform-https
      namespace: argocd
      labels:
        argocd.argoproj.io/secret-type: repo-creds
    stringData:
      url: "${aws_codecommit_repository.workloads_repo_cc.clone_url_http}"
      password: "${aws_iam_service_specific_credential.argocd_codecommit_credential.service_password}"
      username: "${aws_iam_service_specific_credential.argocd_codecommit_credential.service_user_name}"
    EOF

  depends_on = [
    module.eks_blueprints
  ]
}
