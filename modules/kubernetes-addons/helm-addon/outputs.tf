output "helm_release_addon_name" {
  description = "Release name."
  value       = helm_release.addon[0].name
}

output "helm_release_addon_repository" {
  description = "Repository URL where to locate the requested chart."
  value       = helm_release.addon[0].repository
}

output "helm_release_addon_chart" {
  description = "Chart name to be installed."
  value       = helm_release.addon[0].chart
}

output "helm_release_addon_version" {
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
  value       = helm_release.addon[0].version
}

output "helm_release_addon_timeout" {
  description = " Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to 300 seconds."
  value       = helm_release.addon[0].timeout
}

output "helm_release_addon_values" {
  description = "List of values in raw yaml to pass to helm."
  value       = helm_release.addon[0].values
}

output "helm_release_addon_create_namespace" {
  description = "Create the namespace if it does not yet exist. Defaults to false."
  value       = helm_release.addon[0].create_namespace
}

output "helm_release_addon_namespace" {
  description = "The namespace to install the release into. Defaults to default."
  value       = helm_release.addon[0].namespace
}

output "helm_release_addon_lint" {
  description = "Run the helm chart linter during the plan. Defaults to false."
  value       = helm_release.addon[0].lint
}

output "helm_release_addon_description" {
  description = "Set release description attribute (visible in the history)."
  value       = helm_release.addon[0].description
}

output "helm_release_addon_verify" {
  description = "Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart. For more information see the Helm Documentation. Defaults to false."
  value       = helm_release.addon[0].verify
}

output "helm_release_addon_keyring" {
  description = "Location of public keys used for verification. Used only if verify is true. Defaults to /.gnupg/pubring.gpg in the location set by home"
  value       = helm_release.addon[0].keyring
}

output "helm_release_addon_disable_webhooks" {
  description = "Prevent hooks from running. Defaults to false."
  value       = helm_release.addon[0].disable_webhooks
}

output "helm_release_addon_reuse_values" {
  description = "When upgrading, reuse the last release's values and merge in any overrides. If 'reset_values' is specified, this is ignored. Defaults to false."
  value       = helm_release.addon[0].reuse_values
}

output "helm_release_addon_reset_values" {
  description = "When upgrading, reset the values to the ones built into the chart. Defaults to false."
  value       = helm_release.addon[0].reset_values
}

output "helm_release_addon_force_update" {
  description = "Force resource update through delete/recreate if needed. Defaults to false."
  value       = helm_release.addon[0].force_update
}

output "helm_release_addon_recreate_pods" {
  description = "Perform pods restart during upgrade/rollback. Defaults to false."
  value       = helm_release.addon[0].recreate_pods
}

output "helm_release_addon_cleanup_on_fail" {
  description = "Allow deletion of new resources created in this upgrade when upgrade fails. Defaults to false."
  value       = helm_release.addon[0].cleanup_on_fail
}

output "helm_release_addon_max_history" {
  description = "Maximum number of release versions stored per release. Defaults to 0 (no limit)."
  value       = helm_release.addon[0].max_history
}

output "helm_release_addon_atomic" {
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Defaults to false."
  value       = helm_release.addon[0].atomic
}

output "helm_release_addon_skip_crds" {
  description = "If set, no CRDs will be installed. By default, CRDs are installed if not already present. Defaults to false."
  value       = helm_release.addon[0].skip_crds
}

output "helm_release_addon_render_subchart_notes" {
  description = "If set, render subchart notes along with the parent. Defaults to true."
  value       = helm_release.addon[0].render_subchart_notes
}

output "helm_release_addon_disable_openapi_validation" {
  description = "If set, the installation process will not validate rendered templates against the Kubernetes OpenAPI Schema. Defaults to false."
  value       = helm_release.addon[0].disable_openapi_validation
}

output "helm_release_addon_wait" {
  description = "Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as timeout. Defaults to true."
  value       = helm_release.addon[0].wait
}

output "helm_release_addon_wait_for_jobs" {
  description = "If wait is enabled, will wait until all Jobs have been completed before marking the release as successful. It will wait for as long as timeout. Defaults to false."
  value       = helm_release.addon[0].wait_for_jobs
}

output "helm_release_addon_dependency_update" {
  description = "Runs helm dependency update before installing the chart. Defaults to false."
  value       = helm_release.addon[0].dependency_update
}

output "helm_release_addon_replace" {
  description = "Re-use the given name, only if that name is a deleted release which remains in the history. This is unsafe in production. Defaults to false."
  value       = helm_release.addon[0].replace
}
