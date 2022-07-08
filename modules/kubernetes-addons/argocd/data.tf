# ---------------------------------------------------------------------------------------------------------------------
# SSH Key
# ---------------------------------------------------------------------------------------------------------------------

data "aws_secretsmanager_secret" "ssh_key" {
  for_each = { for k, v in var.applications : k => v if try(v.ssh_key_secret_name, null) != null }
  name     = each.value.ssh_key_secret_name
}

data "aws_secretsmanager_secret_version" "ssh_key_version" {
  for_each  = { for k, v in var.applications : k => v if try(v.ssh_key_secret_name, null) != null }
  secret_id = data.aws_secretsmanager_secret.ssh_key[each.key].id
}
