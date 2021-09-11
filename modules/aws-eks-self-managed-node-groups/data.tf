data "aws_caller_identity" "current" {}

//data "aws_ssm_parameter" "amazonlinux2eks_ami_id" {
//  name            = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2/recommended/image_id"
//  with_decryption = false
//}
//
//data "aws_ssm_parameter" "bottlerocket_ami_id" {
//  name            = "/aws/service/bottlerocket/aws-k8s-${var.cluster_version}/x86_64/latest/image_id"
//  with_decryption = false
//}

