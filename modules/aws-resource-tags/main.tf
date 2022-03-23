locals {
  org         = var.org
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  resource    = var.resource
  delimiter   = "-"
  input_tags  = var.tags

  id = join(local.delimiter, [local.tenant, local.environment, local.zone, local.resource])

  tags_context = {
    name        = local.id
    org         = local.org
    tenant      = local.tenant
    environment = local.environment
    zone        = local.zone
    resource    = local.resource
  }
  tags = merge(local.tags_context, local.input_tags)
}
