variable "cluster_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.21"
}

variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "teams"
}

variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default     = "dev"
}

variable "teams" {
  description = "Team configuration for the blueprint."
  type = object({
    admin_users     = list(string)
    team_red_users  = list(string)
    team_blue_users = list(string)
  })
  default = {
    admin_users     = []
    team_blue_users = []
    team_red_users  = []
  }
}
