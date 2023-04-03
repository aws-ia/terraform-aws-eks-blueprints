output "release_metadata" {
  description = "Map of attributes of the Helm release metadata"
  value       = module.helm_addon.release_metadata
}

