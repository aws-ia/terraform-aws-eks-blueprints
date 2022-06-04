output "mwaa_role_arn" {
  value = aws_iam_role.mwaa_role.arn
}

output "mwaa_role_name" {
  value = aws_iam_role.mwaa_role.id
}

output "mwaa_security_group" {
  value = aws_security_group.mwaa_sg.id
}

output "aws_s3_bucket" {
  value = aws_s3_bucket.mwaa_content.id
}

