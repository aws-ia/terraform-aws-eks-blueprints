variable "project_name" {
  description = "Name of the project to be prefixed to create the s3 bucket"
  type        = string
}
variable "tags" {
  description = "Tags to be associated with the S3 bucket"
  type        = map(any)
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}