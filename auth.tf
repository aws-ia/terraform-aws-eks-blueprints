//
//resource "kubernetes_config_map" "aws_auth" {
//  count      = var.create_eks && var.manage_aws_auth ? 1 : 0
//  depends_on = [module.eks.cluster_id, module.managed-node-groups]
//
//  metadata {
//    name      = "aws-auth"
//    namespace = "kube-system"
//    labels = merge(
//      {
//        "app.kubernetes.io/managed-by" = "Terraform"
//        "terraform.io/module" = "terraform-aws-modules.eks.aws"
//      },
//      var.aws_auth_additional_labels
//    )
//  }
//
//  data = {
//    mapRoles = yamlencode(
//      distinct(concat(
//        local.common_roles,
//        var.map_roles,
//      ))
//    )
//    mapUsers    = yamlencode(var.map_users)
//    mapAccounts = yamlencode(var.map_accounts)
//  }
//}


//
//resource "null_resource" "wait_for_cluster" {
//  count      = var.apply_config_map_aws_auth ? 1 : 0
//  depends_on = [module.eks.cluster_id]
//
//  provisioner "local-exec" {
//    command     = var.wait_for_cluster_command
//    interpreter = var.local_exec_interpreter
//    environment = {
//      ENDPOINT = module.eks.cluster_endpoint
//    }
//  }
//}
//
//resource "kubernetes_config_map" "aws_auth" {
//  count      = var.apply_config_map_aws_auth ? 1 : 0
//  depends_on = [null_resource.wait_for_cluster[0]]
//
//  metadata {
//    name      = "aws-auth"
//    namespace = "kube-system"
//  }
//
//  data = {
//    mapRoles    = replace(yamlencode(distinct(concat(local.rbac_roles, var.map_additional_iam_roles))), "\"", local.yaml_quote)
//    mapUsers    = replace(yamlencode(var.map_additional_iam_users), "\"", local.yaml_quote)
//    mapAccounts = replace(yamlencode(var.map_additional_aws_accounts), "\"", local.yaml_quote)
//  }
//}