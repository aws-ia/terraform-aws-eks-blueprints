# output "client_instance_ssh_command" {
#   description = "Command to quickly validate if the solution worked"
#   value = format("%s %s %s",
#     "ssh -i '${var.ssh_key_local_path}/${var.aws_key_pair_name}.pem'",
#     "ec2-user@${module.client_instance.public_dns}",
#     "curl -ks ${module.eks.cluster_endpoint}/readyz"
#   )
# }
