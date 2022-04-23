locals {
  namespace            = "appmesh-system"
  name                 = "aws-app-mesh"
  service_account_name = "${local.name}-sa"
  aws_region_name      = data.aws_region.current.name

  default_helm_config = {
    name             = "appmesh-controller"
    chart            = "appmesh-controller"
    repository       = "https://aws.github.io/eks-charts"
    version          = "1.4.6"
    namespace        = local.namespace
    timeout          = "1200"
    create_namespace = false
    description      = "AWS App Mesh Helm Chart"
    values           = local.default_helm_values
  }

  default_helm_values = []

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = true
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.appmesh.arn], var.irsa_policies)
  }


  set_values = [{
    name  = "serviceAccount.name"
    value = local.service_account_name
    },
    {
      name  = "serviceAccount.create"
      value = false
    },
    {
      name  = "region"
      value = local.aws_region_name
    }
  ]

}
