output "ssm_start_session" {
  description = "SSM start session command to connect to remote host created"
  value       = "aws ssm start-session --region ${local.region} --target ${module.client_ec2_instance.id}"
}

output "ssm_test" {
  description = "SSM commands to test connectivity from client EC2 instance to the private EKS cluster"
  value       = <<-EOT

    COMMAND="curl -ks ${module.eks.cluster_endpoint}/readyz"

    COMMAND_ID=$(aws ssm send-command --region ${local.region} \
    --document-name "AWS-RunShellScript" \
    --parameters "commands=[$COMMAND]" \
    --targets "Key=instanceids,Values=${module.client_ec2_instance.id}" \
    --query 'Command.CommandId' \
    --output text)

    aws ssm get-command-invocation --region ${local.region} \
    --command-id $COMMAND_ID \
    --instance-id ${module.client_ec2_instance.id} \
    --query 'StandardOutputContent' \
    --output text
  EOT
}

output "cluster_endpoint_private" {
  description = "Command to set the EKS API server endpoint access private"
  value       = <<-EOT

    aws eks update-cluster-config \
    --region ${local.region} \
    --name ${module.eks.cluster_name} \
    --resources-vpc-config endpointPublicAccess=false,endpointPrivateAccess=true
  EOT
}

output "cluster_endpoint_public" {
  description = "Command to set the EKS API server endpoint access private"
  value       = <<-EOT

    aws eks update-cluster-config \
    --region ${local.region} \
    --name ${module.eks.cluster_name} \
    --resources-vpc-config endpointPublicAccess=true,endpointPrivateAccess=true
  EOT
}
