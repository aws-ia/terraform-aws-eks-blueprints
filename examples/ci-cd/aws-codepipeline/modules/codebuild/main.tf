# Codebuild project for Validation and Planning

resource "aws_codebuild_project" "codebuild" {

  name         = "${var.project_name}-${var.code_build_name}"
  service_role = var.role_arn
  artifacts {
    type = "CODEPIPELINE"
  }
  tags = var.tags
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "VALIDATE_BUILD_NAME"
      value = "${var.project_name}-Validate"
    }
    environment_variable {
      name  = "PLAM_BUILD_NAME"
      value = "${var.project_name}-Plan"
    }
    environment_variable {
      name  = "APPLY_BUILD_NAME"
      value = "${var.project_name}-Apply"
    }
    environment_variable {
      name  = "DESTROY_BUILD_NAME"
      value = "${var.project_name}-Destroy"
    }
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = var.build_spec_file_path
  }
}
