output "arn" {
  value       = aws_kms_key.encryption_key.arn
  description = "The ARN of the KMS key"
}