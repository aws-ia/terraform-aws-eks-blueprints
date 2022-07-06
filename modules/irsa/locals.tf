locals {
  timeouts = {
    create = lookup(var.timeouts, "create", "10m")
    delete = lookup(var.timeouts, "delete", "10m")
  }
}
