output "ssm_start_session" {
  description = "SSM start session command to connect to remote host created"
  value       = "aws ssm start-session --region ${local.region} --target ${module.client_ec2_instance.id}"
}

output "ssm_test" {
  description = "SSM start session command to connect to remote host created"
  value       = <<-EOT
    COMMAND_ID=$(aws ssm send-command --region ${local.region} --document-name "AWS-RunShellScript" \
    --parameters 'commands=["curl -ks ${module.eks.cluster_endpoint}/readyz"]' \
    --targets "Key=instanceids,Values=${module.client_ec2_instance.id}" --query 'Command.CommandId' --output text)

    aws ssm get-command-invocation --region ${local.region} --command-id $COMMAND_ID --instance-id ${module.client_ec2_instance.id} --query 'StandardOutputContent' --output text
  EOT
}
