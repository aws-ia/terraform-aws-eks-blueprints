data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.ecr
}

################################################################################
# Helm charts
################################################################################

resource "helm_release" "neuron" {
  name             = "neuron"
  repository       = "oci://public.ecr.aws/neuron"
  chart            = "neuron-helm-chart"
  version          = "1.1.1"
  namespace        = "neuron"
  create_namespace = true
  wait             = false

  # Public ECR
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password

  values = [
    <<-EOT
      nodeSelector:
        aws.amazon.com/neuron.present: 'true'
      npd:
        enabled: false
    EOT
  ]
}

resource "helm_release" "aws_efa_device_plugin" {
  name       = "aws-efa-k8s-device-plugin"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-efa-k8s-device-plugin"
  version    = "v0.5.7"
  namespace  = "kube-system"
  wait       = false

  values = [
    <<-EOT
      nodeSelector:
        vpc.amazonaws.com/efa.present: 'true'
      tolerations:
        - key: aws.amazon.com/neuron
          operator: Exists
          effect: NoSchedule
    EOT
  ]
}
