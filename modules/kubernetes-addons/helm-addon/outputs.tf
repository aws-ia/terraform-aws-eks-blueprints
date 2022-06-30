output "helm_release_addon" {
  description = "Describes the desired status of a chart in a kubernetes cluster."
  value = try(
    {
      for k, v in helm_release.external-dns : k => (
        k != "repository_password" ? v : null
      )
    }, null
  )
}
