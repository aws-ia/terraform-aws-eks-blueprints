locals {
  kubernetes_timeouts = {
    create = lookup(var.kubernetes_timeouts, "create", "10m")
    delete = lookup(var.kubernetes_timeouts, "delete", "10m")
  }
}
