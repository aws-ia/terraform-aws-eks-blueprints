# CodePipeline

resource "aws_codepipeline" "pipeline" {

  name     = "${var.project_name}-pipeline-${var.source_repo_name}-${var.source_repo_branch}"
  role_arn = var.codepipeline_role_arn
  tags     = var.tags

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Download-Source"
      category         = "Source"
      owner            = var.namespace
      version          = "1"
      provider         = "CodeCommit"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceOutput"]
      run_order        = 1
      configuration = {
        RepositoryName       = var.source_repo_name
        BranchName           = var.source_repo_branch
        PollForSourceChanges = "false"
      }
    }
  }
  stage {
    name = "Validate-Plan-Apply-Destroy"
    action {
      name             = "Validate"
      category         = "Test"
      owner            = var.namespace
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["ValidateOutput"]
      run_order        = 2
      configuration = {
        ProjectName = var.codebuild_validate_project_arn
      }
    }
    action {
      name             = "Plan"
      category         = "Test"
      owner            = var.namespace
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["PlanOutput"]
      run_order        = 3
      configuration = {
        ProjectName = var.codebuild_plan_project_arn
      }
    }
    action {
      name             = "Apply"
      category         = "Test"
      owner            = var.namespace
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["ApplyOutput"]
      run_order        = 4
      configuration = {
        ProjectName = var.codebuild_apply_project_arn
      }
    }
  }
  stage {
    name = "Approve"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }
  stage {
    name = "Destroy"

    action {
      name             = "Destroy"
      category         = "Build"
      owner            = var.namespace
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["PlanOutput"]
      output_artifacts = ["DestroyOutput"]
      run_order        = 5
      configuration = {
        ProjectName   = var.codebuild_apply_project_arn
        PrimarySource = "Source"
      }
    }
  }
}
