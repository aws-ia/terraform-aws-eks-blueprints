output "created_repository" {
  description = "The github repository that had been created."
  value = try(github_repository.loosely_coupled[0], github_repository.tightly_coupled[0])
}