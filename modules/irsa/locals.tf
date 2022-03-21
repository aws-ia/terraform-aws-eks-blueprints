terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  addon_context = defaults(var.addon_context, {
    irsa_iam_role_path            = "/"
    irsa_iam_permissions_boundary = ""
  })
}