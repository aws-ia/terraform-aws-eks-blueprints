project_name       = "terraform-test"
environment        = "dev"
source_repo_name   = "terraform-repo"
source_repo_branch = "main"
create_new_repo    = false
stage_input = [{ name = "Validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput", build_name = "terraform-test-validate" },
  { name = "Plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "PlanOutput", build_name = "terraform-test-plan" },
  { name = "Apply-Approval", category = "Approval", owner = "AWS", provider = "Manual", input_artifacts = "", output_artifacts = "", build_name = null },
  { name = "Apply", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ApplyOutput", build_name = "terraform-test-apply" },
  { name = "Destroy-Approval", category = "Approval", owner = "AWS", provider = "Manual", input_artifacts = "", output_artifacts = "", build_name = null },
{ name = "Destroy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "DestroyOutput", build_name = "terraform-test-destroy" }]
build_projects = ["validate", "plan", "apply", "destroy"]
