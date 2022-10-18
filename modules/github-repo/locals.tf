locals {
  template_owner = var.template_owner == "" ? var.provider_owner : var.template_owner
}