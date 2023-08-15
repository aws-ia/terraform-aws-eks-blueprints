variable "admin_user_config" {
  description = "Configuration for Platform Admin Users."
  type = list(object({
    family_name = string
    given_name  = string
    email       = string
  }))
  default = [{
    family_name = "Admin"
    given_name  = "Platform"
    email       = "admin@example.com"
  }]
}

variable "user_config" {
  description = "Configuration for Developer Users."
  type = list(object({
    family_name = string
    given_name  = string
    email       = string
  }))
  default = [{
    family_name = "User1"
    given_name  = "Developer"
    email       = "user1@example.com"
    },
    {
      family_name = "User2"
      given_name  = "Developer"
      email       = "user2@example.com"
    }
  ]
}
