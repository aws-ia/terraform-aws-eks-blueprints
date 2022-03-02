terraform {
  experiments = [module_variable_optional_attrs]
}

locals {
  irsa_config = defaults(var.irsa_config, {
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    iam_role_path                     = "/"
    tags                              = null
    irsa_iam_policies                 = []
    irsa_iam_permissions_boundary     = ""
  })
}