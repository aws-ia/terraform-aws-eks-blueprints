output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "okta_login" {
  description = "Setup OIDC Login for OKTA."
  value       = "kubectl oidc-login setup --oidc-issuer-url=${okta_auth_server.eks.issuer} --oidc-client-id=${okta_app_oauth.eks.id}"
}

output "configure_kubeconfig" {
  description = "Update kubeconfig with OKTA OIDC parameters."
  value       = <<EOT
    kubectl config set-credentials oidc \
      --exec-api-version=client.authentication.k8s.io/v1beta1 \
      --exec-command=kubectl \
      --exec-arg=oidc-login \
      --exec-arg=get-token \
      --exec-arg=--oidc-issuer-url=${okta_auth_server.eks.issuer} \
      --exec-arg=--oidc-client-id=${okta_app_oauth.eks.id} \
      --exec-arg=--oidc-extra-scope="email offline_access profile openid"
  EOT
}

