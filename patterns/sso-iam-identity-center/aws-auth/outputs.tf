output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "configure_sso_admins" {
  description = "Example configuration for SSO with provisioned Admin user."
  value       = <<EOT
  # aws configure sso
  SSO session name (Recommended): <SESSION_NAME>
  SSO start URL [None]: https://${tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]}.awsapps.com/start
  SSO region [None]: ${local.region}
  SSO registration scopes [sso:account:access]:
  Attempting to automatically open the SSO authorization page in your default browser.
  If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

  https://device.sso.us-west-2.amazonaws.com/

  Then enter the code:

  The only AWS account available to you is: ${data.aws_caller_identity.current.account_id}
  Using the account ID ${data.aws_caller_identity.current.account_id}
  The only role available to you is: ${aws_ssoadmin_permission_set.admin.name}
  Using the role name ${aws_ssoadmin_permission_set.admin.name}
  CLI default client Region [${local.region}]: ${local.region}
  CLI default output format [json]: json
  CLI profile name [${aws_ssoadmin_permission_set.admin.name}-${data.aws_caller_identity.current.account_id}]:

  To use this profile, specify the profile name using --profile, as shown:

  aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name} --profile ${aws_ssoadmin_permission_set.admin.name}-${data.aws_caller_identity.current.account_id}
EOT
}

output "configure_sso_users" {
  description = "Example configuration for SSO with provisioned read-only User."
  value       = <<EOT
  # aws configure sso
  SSO session name (Recommended): <SESSION_NAME>
  SSO start URL [None]: https://${tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]}.awsapps.com/start
  SSO region [None]: ${local.region}
  SSO registration scopes [sso:account:access]:
  Attempting to automatically open the SSO authorization page in your default browser.
  If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

  https://device.sso.us-west-2.amazonaws.com/

  Then enter the code:

  The only AWS account available to you is: ${data.aws_caller_identity.current.account_id}
  Using the account ID ${data.aws_caller_identity.current.account_id}
  The only role available to you is: ${aws_ssoadmin_permission_set.user.name}
  Using the role name ${aws_ssoadmin_permission_set.user.name}
  CLI default client Region [${local.region}]: ${local.region}
  CLI default output format [json]: json
  CLI profile name [${aws_ssoadmin_permission_set.user.name}-${data.aws_caller_identity.current.account_id}]:

  To use this profile, specify the profile name using --profile, as shown:

  aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name} --profile ${aws_ssoadmin_permission_set.user.name}-${data.aws_caller_identity.current.account_id}
EOT
}
