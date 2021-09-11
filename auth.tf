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
//module "aws-auth" {
//
//
//  depends_on = [eks, mana, farga, self, rbac]
//}