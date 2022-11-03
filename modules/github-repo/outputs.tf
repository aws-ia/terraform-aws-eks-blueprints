output "url" {
  description = "Created repository's url."
  value       = github_repository.repository.html_url
}