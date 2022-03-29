variable "policy" {
  type        = string
  description = "A valid KMS key policy JSON document. Although this is a key policy, not an IAM policy, an aws_iam_policy_document, in the form that designates a principal, can be used."
}

variable "description" {
  type        = string
  description = "The description of the key."
}

variable "alias" {
  type        = string
  description = "The display name of the alias. The name must start with the word 'alias' followed by a forward slash (alias/)"
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Specifies whether annual key rotation is enabled."
}

variable "deletion_window_in_days" {
  type        = number
  default     = 30
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive. If you do not specify a value, it defaults to 30."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the object."
}
