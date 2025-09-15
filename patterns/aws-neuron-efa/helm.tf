data "aws_ecrpublic_authorization_token" "token" {
  region = "us-east-1"
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }

    registries = [
      {
        url      = "oci://public.ecr.aws/neuron"
        username = data.aws_ecrpublic_authorization_token.token.user_name
        password = data.aws_ecrpublic_authorization_token.token.password
      }
    ]
  }
}

################################################################################
# Helm charts
################################################################################

resource "helm_release" "neuron" {
  name             = "neuron"
  repository       = "oci://public.ecr.aws/neuron"
  chart            = "neuron-helm-chart"
  version          = "1.2.0"
  namespace        = "neuron"
  create_namespace = true
  wait             = false

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
  version    = "v0.5.17"
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
