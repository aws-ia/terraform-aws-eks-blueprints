terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
  }

  backend "s3" {
    bucket = "arj-giga-bucket"
    key    = "states/pipeline.tfstate"
    region = "us-east-2"
  }
}

# Module for Consistent Tagging
module "resource-label" {
  source    = "aws-ia/label/aws"
  version   = "0.0.4"
  name      = var.project_name
  namespace = var.namespace
  env       = var.ENVIRONMENT
  account   = var.account_id

}

#Module for creating a new S3 bucket for storing pipeline artifacts
module "s3_artifacts_bucket" {
  source = "./modules/s3"

  project_name = var.project_name
  tags         = { name="arj" }
}

# Resources

# Module for Infrastructure Source code repository
module "codecommit_infrastructure_source_repo" {
  source = "./modules/codecommit"

  create_new_repo        = var.create_new_repo
  source_repository_name = var.source_repo_name
  source_repository_tags = { name="arj" }

}

# Module for Infrastructure Validation - CodeBuild
module "codebuild_terraform_validate" {
  depends_on = [
    module.codecommit_infrastructure_source_repo
  ]
  source = "./modules/codebuild"

  project_name           = var.project_name
  build_spec_file_path   = var.build_spec_file_path_validate
  code_build_name        = "Validate"
  role_arn = module.codepipeline-iam-role.role_arn
  s3_bucket_name         = module.s3_artifacts_bucket.bucket
  tags                   = { name="arj" }

}

# Module for Infrastructure Plan - CodeBuild
module "codebuild_terraform_plan" {
  depends_on = [
    module.codebuild_terraform_validate
  ]
  source = "./modules/codebuild"

  project_name           = var.project_name
  build_spec_file_path   = var.build_spec_file_path_plan
  code_build_name        = "Plan"
  role_arn = module.codepipeline-iam-role.role_arn
  s3_bucket_name         = module.s3_artifacts_bucket.bucket
  tags                   = { name="arj" }

}

# Module for Infrastructure Apply - CodeBuild
module "codebuild_terraform_apply" {
  depends_on = [
    module.codebuild_terraform_plan
  ]
  source = "./modules/codebuild"

  project_name           = var.project_name
  build_spec_file_path   = var.build_spec_file_path_apply
  code_build_name        = "Apply"
  role_arn = module.codepipeline-iam-role.role_arn
  s3_bucket_name         = module.s3_artifacts_bucket.bucket
  tags                   = { name="arj" }

}

# Module for Infrastructure Destroy - CodeBuild
module "codebuild_terraform_destroy" {
  depends_on = [
    module.codebuild_terraform_apply
  ]
  source = "./modules/codebuild"

  project_name           = var.project_name
  build_spec_file_path   = var.build_spec_file_path_destroy
  code_build_name        = "Destroy"
  role_arn = module.codepipeline-iam-role.role_arn
  s3_bucket_name         = module.s3_artifacts_bucket.bucket
  tags                   = { name="arj" }

}
module "codepipeline-iam-role"{
  source = "./modules/iam-role"
  project_name           = var.project_name
}
# Module for Infrastructure Validate, Plan, Apply and Destroy - CodePipeline
module "codepipeline_terraform_validate_plan_apply_destroy" {
  depends_on = [
    module.codebuild_terraform_validate,
    module.codebuild_terraform_plan,
    module.codebuild_terraform_apply,
    module.codebuild_terraform_destroy,
    module.s3_artifacts_bucket
  ]
  source = "./modules/codepipeline"

  account_id                     = var.account_id
  namespace                      = var.namespace
  project_name                   = var.project_name
  source_repo_name               = var.source_repo_name
  source_repo_branch             = var.source_repo_branch
  s3_bucket_name                 = module.s3_artifacts_bucket.bucket
  codepipeline_role_arn = module.codepipeline-iam-role.role_arn
  codebuild_validate_project_arn = module.codebuild_terraform_validate.arn
  codebuild_plan_project_arn     = module.codebuild_terraform_plan.arn
  codebuild_apply_project_arn    = module.codebuild_terraform_apply.arn
  codebuild_destroy_project_arn  = module.codebuild_terraform_destroy.arn
  tags                           = { name="arj" }
}
