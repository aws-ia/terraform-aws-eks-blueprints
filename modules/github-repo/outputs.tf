output "repo_url" {
  description = "Github repository url."
  value = try(data.terraform_remote_state.state_file[0].outputs.repo_url, github_repository.repository[0].html_url, null)

  depends_on = [
    data.terraform_remote_state.state_file,
    github_repository.repository
  ]
}