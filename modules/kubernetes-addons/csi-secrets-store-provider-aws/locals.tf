locals {
  default_helm_values = [try(file("${path.module}/values.yaml"), null)]

  name      = "csi-secrets-store-provider-aws"
  namespace = "csi-secrets-store-provider-aws"

  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/Chart.yaml
  default_helm_config = {
    name             = local.name
    chart            = local.name
    repository       = "https://aws.github.io/eks-charts"
    version          = "0.0.3"
    namespace        = local.namespace
    create_namespace = true
    values           = local.default_helm_values
    description      = "A Helm chart to install the Secrets Store CSI Driver and the AWS Key Management Service Provider inside a Kubernetes cluster."
    wait             = false
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )
}
