output "data_http_karpenter_crd_provisioners" {
  description = "The http data source makes an HTTP GET request karpenter provisioners CRD."
  value       = data.http.karpenter_crd_provisioners.response_body
}

output "kubectl_manifest_karpenter_crd_provisioners" {
  description = "Create a Kubernetes resource using karpenter provisioners CRD manifests."
  value       = try({ for k, v in kubectl_manifest.karpenter_crd_provisioners : k => (k != "live_manifest_incluster" && k != "yaml_body" && k != "yaml_incluster" ? v : null) }, null)
}

output "data_http_karpenter_crd_awsnodetemplates" {
  description = "The http data source makes an HTTP GET request karpenter awsnodetemplates CRD."
  value       = data.http.karpenter_crd_awsnodetemplates.response_body
}

output "kubectl_manifest_karpenter_crd_awsnodetemplates" {
  description = "Create a Kubernetes resource using karpenter awsnodetemplates CRD manifests."
  value       = try({ for k, v in kubectl_manifest.karpenter_crd_awsnodetemplates : k => (k != "live_manifest_incluster" && k != "yaml_body" && k != "yaml_incluster" ? v : null) }, null)
}

output "aws_iam_policy_karpenter" {
  description = "Provides an IAM policy for karpenter."
  value       = aws_iam_policy.karpenter
}

output "helm_addon_karpenter" {
  description = "Karpenter helm chart release."
  value       = module.helm_addon
}
