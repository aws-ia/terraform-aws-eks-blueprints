variable "policy" {
  description = "A valid KMS key policy JSON document. Although this is a key policy, not an IAM policy, an aws_iam_policy_document, in the form that designates a principal, can be used"
  type        = string
}

variable "description" {
  description = "The description of the key"
  type        = string
}

variable "alias" {
  description = "The display name of the alias. The name must start with the word 'alias' followed by a forward slash (alias/)"
  type        = string
}

variable "enable_key_rotation" {
  description = "Specifies whether annual key rotation is enabled"
  type        = bool
  default     = true
}

variable "deletion_window_in_days" {
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive. If you do not specify a value, it defaults to 30"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to assign to the object"
  type        = map(string)
}
