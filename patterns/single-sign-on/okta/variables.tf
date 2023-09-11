variable "admin_user_config" {
  description = "Configuration for Platform Admin Users."
  type = list(object({
    last_name  = string
    first_name = string
    email      = string
  }))
  default = [{
    last_name  = "Admin"
    first_name = "Platform"
    email      = "admin@example.com"
  }]
}

variable "user_config" {
  description = "Configuration for Developer Users."
  type = list(object({
    last_name  = string
    first_name = string
    email      = string
  }))
  default = [{
    last_name  = "User1"
    first_name = "Developer"
    email      = "user1@example.com"
    },
    {
      last_name  = "User2"
      first_name = "Developer"
      email      = "user2@example.com"
    }
  ]
}
