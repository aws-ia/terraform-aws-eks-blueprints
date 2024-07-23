# defaults to data.aws_caller_identity.current.account_id
variable "ecr_account_id" {
  type        = string
  description = "ECR repository AWS Account ID"
  default     = ""
}

# defaults to local.region
variable "ecr_region" {
  type        = string
  description = "ECR repository AWS Region"
  default     = ""
}

variable "docker_secret" {
  description = "Inform your docker username and accessToken to allow pullTroughCache to get images from Docekr.io. E.g. `{username='user',accessToken='pass'}`"
  type = object({
    username    = string
    accessToken = string
  })
  sensitive = true
  default = {
    username    = ""
    accessToken = ""
  }
}
