variable "docker_secret" {
  description = "Inform your docker username and accessToken to allow pullTroughCache to get images from Docker.io. E.g. `{username='user',accessToken='pass'}`"
  type = object({
    username    = string
    accessToken = string
  })
  sensitive = true
}
