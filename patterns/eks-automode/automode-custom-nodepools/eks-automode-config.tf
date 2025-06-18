# Yaml manifests are provided under folder ./eks-automode-config/
locals {
  storageclass_yamls = [
    "ebs-storageclass.yaml"
  ]
  ingressclass_yamls = [
    "alb-ingressclass.yaml",
    "alb-ingressclassParams.yaml"
  ]
  custom_nodeclass_yamls = [
    "nodeclass-basic.yaml",
    "nodeclass-ebs-optimized.yaml"
  ]
  custom_nodepool_yamls = [
    "nodepool-amd64.yaml",
    "nodepool-graviton.yaml"
  ]
}

# Apply default storage class for EKS AutoMode. EBS CSI Driver runs on AWS side, managed by AWS.
resource "kubectl_manifest" "storageclass_yamls" {
  for_each = toset(local.storageclass_yamls)

  yaml_body = file("${path.module}/eks-automode-config/${each.value}")
}

# Apply default ingress class for EKS AutoMode plus ingress class parameters. AWS Load Balancer Controller runs on AWS side, managed by AWS.
resource "kubectl_manifest" "ingressclass_yamls" {
  for_each = toset(local.ingressclass_yamls)

  yaml_body = file("${path.module}/eks-automode-config/${each.value}")
}

# Apply custom nodeclass objects
resource "kubectl_manifest" "custom_nodeclass" {
  for_each = toset(local.custom_nodeclass_yamls)

  yaml_body = templatefile("${path.module}/eks-automode-config/${each.value}", {
    node_iam_role_name = aws_iam_role.custom_nodeclass_role.name
    cluster_name       = module.eks.cluster_name
  })

}

# Apply custom nodepool objects
resource "kubectl_manifest" "custom_nodepool" {
  for_each = toset(local.custom_nodepool_yamls)

  yaml_body = file("${path.module}/eks-automode-config/${each.value}")

}
